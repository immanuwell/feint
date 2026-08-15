--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: _br_parse_from_text(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._br_parse_from_text(in_val text, in_re text) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
    /**
      Parse input text value to a double precision if regexp provided allows for that.
      If not, NULL is returned.

      _br_parse_from_text('1d 22.01', '\d+d (\d+.\d+)') -> 22.01
      _br_parse_from_text('1d 22.01', NULL) -> NULL

     */
    declare
        _re_result text;
    begin
    select into _re_result coalesce((regexp_match(in_val, coalesce(in_re, '')))[1], '');
    if _re_result <> '' then
        return _re_result::double precision;
    else
        return NULL;
    end if;
    end;
    $$;


--
-- Name: _get_baserow_table_file_uniques(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._get_baserow_table_file_uniques(table__id integer) RETURNS TABLE(file_unique text, field_id integer, table_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    field RECORD;
    filename TEXT;
BEGIN
FOR field IN EXECUTE 'SELECT * FROM database_field JOIN database_filefield ON id=field_ptr_id WHERE trashed=false AND table_id=' || table__id || ';'
LOOP
    BEGIN
        RETURN QUERY EXECUTE 'SELECT SPLIT_PART(JSONB_ARRAY_ELEMENTS(field_' || field.id || ') ->> ''name'', ''_'', 1), ' || field.id || ', ' || field.table_id || ' FROM database_table_' || field.table_id;
    EXCEPTION
        WHEN undefined_table THEN
            RAISE NOTICE 'Could not find database_table_%', field.table_id;
        WHEN undefined_column THEN
            RAISE NOTICE 'Could not find field_% in database_table_%', field.id, field.table_id;
    END;
END LOOP;
END;
$$;


--
-- Name: br_interval_to_text(interval, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.br_interval_to_text(in_val interval, in_format text, ms_prec integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
    /**
      Converts interval value to text according to a given format.
      The difference from a regular to_char(interval, text) call is:
      * input value is normalized to positive number of seconds
      * if there's a day marker in format string, normalized interval value
        is adjusted so hours value is below 24 (with justify_hours)
      * if input value was negative one, the minus sign will be added to the value at the end.
      * a negative input value doesn't give interval-compatible value in result. It should be
        parsed to interval using br_text_to_interval(text, text) function.
      * if a milisecond marker is provided (`MS`) a rounding may be applied. If a third parameter is provided,
        it will be used to round and truncate miliseconds value to a given precision.
        The precision value should be in range 0..3. If precision is not provided, and
        milisecond


    Examples:

      br_interval_to_text(interval '-1d -23:22:21.0234', 'FMDD"d" HH24"h" MI"m"') -> '-1d 23h 22m'

      br_interval_to_text(interval '-1d -23:22:21.0234', 'FMDD"d" HH24"h" MI"m" SS.MS', 2) -> '-1d 23h 22m 21.02'

      br_interval_to_text(interval '-1d -23:22:21.0264', 'FMDD"d" HH24"h" MI"m" SS.MS', 2) -> '-1d 23h 22m 21.03'

      br_interval_to_text(interval '-1d -23:22:21.0234', 'HH24"h" MI"m"') -> '-47h 22m'

     */
    declare
        _formatted text;
        _interval interval;
        _total_secs double precision;
    begin
    _total_secs = abs(round(extract(epoch from br_interval_to_text.in_val)::numeric, coalesce(ms_prec, 3)));

    _interval = make_interval(secs=>_total_secs);

    /* if we have days in required format, we want to adjust hours to be in 00..24 range
           so 30h becomes 1d 6h
       otherwise, 30h remains 30h
           */
    if in_format ~ 'DD' then
        _interval = justify_hours(_interval);
    end if;

    _formatted =         case when br_interval_to_text.in_val < make_interval(secs=> 0) then '-' else '' end ||
        to_char( _interval, br_interval_to_text.in_format);

    /* this trick here removes trailing digits if MS is used in format and there's a precision set */
    if (in_format ~ '.MS$' and ms_prec is not null and (ms_prec -3 < 0)) then
        _formatted = left(    _formatted, (ms_prec-3));
    end if;

    return _formatted;

    end;
$_$;


--
-- Name: br_text_to_interval(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.br_text_to_interval(in_val text, in_day_re text, in_hour_re text, in_minute_re text, in_sec_re text) RETURNS interval
    LANGUAGE plpgsql
    AS $_$
    /**
      Parses text value describing interval value (created with br_interval_to_text function
      into an interval value.

      in_day_re, in_hour_re, in_minute_re and in_sec_re should be regular expressions
      that parse a specific part of the interval from in_val. Each regexp will be executed
      on in_val, so it can also note previous parts. If all regexps will not match and
      internally return NULL values, this function will return NULL value as well.

      Note that internally all calculations are processed on seconds, so raw results
      won't have year to day part of the interval, even if the number of hours exceeded
      24h. You should use justify_hours() to normalize the result.

      br_text_to_interval('-1d 23h:22m', r'^(\d+)d', r'^\d+d\s*(\d+)h', r'^\d+d\s*\d+h:(\d+)m', null) -> '-47:22:00'
      br_text_to_interval('-1d 23h:22m', r'^(\d+):\d+\d+', NULL, NULL, null) -> NULL

      br_text_to_interval('-1d 10:20:30.47', r'^(\d+)d', r'^\d+d\s*(\d+):', r'^\d+d\s*\d+:(\d+):', r'^\d+d\s*\d+:\d+:(\d+\.?\d+)$') -> '-34:20:30.47'

     */
    declare
        _out_secs double precision := 0;
        _parsed double precision;
        _multi int :=1;
        _parsed_any bool :=false;
    begin

        if starts_with(trim(in_val), '-') then
            _multi = -1;
            in_val = ltrim(trim(in_val), '-');
        end if;

        select into _parsed _br_parse_from_text(in_val, in_day_re) * 24 * 3600;
        _out_secs = _out_secs + coalesce(_parsed, 0.0);
        _parsed_any = _parsed_any or _parsed is not null;

        select into _parsed _br_parse_from_text(in_val, in_hour_re) * 3600;
        _out_secs = _out_secs + coalesce(_parsed, 0.0);
        _parsed_any = _parsed_any or _parsed is not null;

        select into _parsed _br_parse_from_text(in_val, in_minute_re) * 60;
        _out_secs = _out_secs + coalesce(_parsed, 0.0);
        _parsed_any = _parsed_any or _parsed is not null;

        select into _parsed _br_parse_from_text(in_val, in_sec_re);
        _out_secs = _out_secs + coalesce(_parsed, 0.0);
        _parsed_any = _parsed_any or _parsed is not null;

        if _parsed_any then
            return make_interval(secs=>_out_secs * _multi);
        else
            return null;
        end if;
    end;
$_$;


--
-- Name: date_diff(text, timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.date_diff(units text, start_t timestamp with time zone, end_t timestamp with time zone) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
   DECLARE
     diff_interval INTERVAL;
     diff NUMERIC(50, 0) = 0;
     years_diff NUMERIC(50, 0) = 0;
   BEGIN
     IF units IN ('yy', 'yyyy', 'year', 'mm', 'm', 'month') THEN
       years_diff = DATE_PART('year', end_t) - DATE_PART('year', start_t);

       IF units IN ('yy', 'yyyy', 'year') THEN
         -- SQL Server does not count full years passed (only difference between year
         -- parts)
         RETURN years_diff;
       ELSE
         -- If end month is less than start month it will subtracted
         RETURN years_diff * 12 + (DATE_PART('month', end_t) - DATE_PART('month',
                start_t));
       END IF;
     END IF;

     -- Minus operator returns interval 'DDD days HH:MI:SS'
     diff_interval = end_t - start_t;

     diff = diff + DATE_PART('day', diff_interval);

     IF units IN ('wk', 'ww', 'week') THEN
       diff = diff/7;
       RETURN diff;
     END IF;

     IF units IN ('dd', 'd', 'day') THEN
       RETURN diff;
     END IF;

     diff = diff * 24 + DATE_PART('hour', diff_interval);

     IF units IN ('hh', 'hour') THEN
        RETURN diff;
     END IF;

     diff = diff * 60 + DATE_PART('minute', diff_interval);

     IF units IN ('mi', 'n', 'minute') THEN
        RETURN diff;
     END IF;

     IF units IN ('s', 'ss', 'second') THEN
        RETURN diff * 60 + DATE_PART('second', diff_interval);
     END IF;

     RETURN 'NaN';
   END;
   $$;


--
-- Name: get_baserow_table_row_count(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_baserow_table_row_count(table_id integer) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    row_count BIGINT;
BEGIN
    BEGIN
        EXECUTE 'SELECT COUNT(*) FROM database_table_' || table_id || ' WHERE trashed=false;' INTO row_count;
        RETURN row_count;
    EXCEPTION WHEN OTHERS THEN
        return null;
    END;
end;
$$;


--
-- Name: get_distinct_baserow_table_file_uniques(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_distinct_baserow_table_file_uniques(table_id integer) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
    file_uniques TEXT[];
BEGIN
    BEGIN
        EXECUTE 'SELECT array_agg(distinct file_unique) from _get_baserow_table_file_uniques(' || table_id || ');' into file_uniques;
        return file_uniques;
    EXCEPTION WHEN OTHERS THEN
        return null;
    END;
END;
$$;


--
-- Name: replace_errors_with_nan(anyelement); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.replace_errors_with_nan(p_in anyelement) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
    begin
        begin
            IF p_in < 10^50 OR p_in is null THEN
                return p_in;
            ELSE
                return 'NaN';
            END IF;
        exception when others then
            return 'NaN';
        end;
    end;
    $$;


--
-- Name: replace_errors_with_null(anyelement); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.replace_errors_with_null(p_in anyelement) RETURNS anyelement
    LANGUAGE plpgsql
    AS $$
    begin
        begin
            return p_in;
        exception when others then
            return null;
        end;
    end;
    $$;


--
-- Name: row_exists_not_trashed(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.row_exists_not_trashed(p_table_id integer, p_row_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE
    table_name text;
    result boolean;
BEGIN
    table_name := 'database_table_' || p_table_id;

    IF NOT EXISTS (
        SELECT 1 FROM pg_class WHERE relname = table_name AND relkind = 'r'
    ) THEN
        RETURN false;
    END IF;

    EXECUTE format(
        'SELECT EXISTS(SELECT 1 FROM %I WHERE id = $1 AND trashed = false)',
        table_name
    ) INTO result USING p_row_id;

    RETURN COALESCE(result, false);
END;
$_$;


--
-- Name: try_cast_to_date(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_cast_to_date(p_in text, p_format text) RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $$
begin
    begin
        return to_timestamp(p_in, p_format);
    exception when others then
        return null;
    end;
end;
$$;


--
-- Name: try_cast_to_date_tz(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_cast_to_date_tz(p_in text, p_format text, p_timezone text) RETURNS timestamp with time zone
    LANGUAGE plpgsql
    AS $$
declare
    tstamp timestamp := null;
begin
    begin
        tstamp := to_timestamp(p_in, p_format);
        return (tstamp AT TIME ZONE p_timezone);
    exception when others then
        return null;
    end;
end;
$$;


--
-- Name: try_cast_to_interval(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_cast_to_interval(p_in text) RETURNS interval
    LANGUAGE plpgsql
    AS $$
begin
    begin
        return p_in::interval;
    exception when others then
        return null;
    end;
end;
$$;


--
-- Name: try_cast_to_numeric(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_cast_to_numeric(p_in text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
begin
    begin
        return p_in::numeric(55, 5);
    exception when others then
        return 'NaN';
    end;
end;
$$;


--
-- Name: try_cast_to_url(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_cast_to_url(input_text text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
BEGIN
    IF input_text ~ '^(?:([a-zA-Z]+):\/\/)?(?:([a-zA-Z0-9._%+-]+)(:[a-zA-Z0-9._%+-]+)?@)?([a-zA-Z0-9.-]+)(?::(\d+))?(\/[^?]*)?(\?.*)?(#.*)?$' THEN
        RETURN input_text;
    ELSE
        RETURN '';
    END IF;
END;
$_$;


--
-- Name: try_datetime_format_tz(timestamp with time zone, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_datetime_format_tz(p_in timestamp with time zone, p_format text, p_timezone text) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
    return to_char(p_in at time zone p_timezone, p_format);
exception when others then
    return null;
end;
$$;


--
-- Name: try_encode_uri(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_encode_uri(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    select string_agg(
        case
            when bytes > 1 or c !~ '[0-9a-zA-Z_.!~*''();,/?:@&=+$#-]+' then
                regexp_replace(encode(convert_to(c, 'utf-8')::bytea, 'hex'), '(..)', E'%\\1', 'g')
            else
                c
        end,
        ''
    )
    from (
        select c, octet_length(c) bytes
        from regexp_split_to_table($1, '') c
    ) q;
$_$;


--
-- Name: try_encode_uri_component(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_encode_uri_component(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    select string_agg(
        case
            when bytes > 1 or c !~ '[0-9a-zA-Z_.!~*''()-]+' then
                regexp_replace(encode(convert_to(c, 'utf-8')::bytea, 'hex'), '(..)', E'%\\1', 'g')
            else
                c
        end,
        ''
    )
    from (
        select c, octet_length(c) bytes
        from regexp_split_to_table($1, '') c
    ) q;
$_$;


--
-- Name: try_regexp_replace(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_regexp_replace(input_string text, pattern text, replacement text, flags text DEFAULT 'g'::text, error_value text DEFAULT ''::text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    result TEXT;
BEGIN
    result := regexp_replace(input_string, pattern, replacement, flags);
    RETURN result;

EXCEPTION
    WHEN others THEN
        RETURN error_value;
END;
$$;


--
-- Name: try_set_tsv(regconfig, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_set_tsv(r regconfig, p_in text) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
BEGIN
    BEGIN
        RETURN to_tsvector(r, p_in);
    EXCEPTION WHEN others THEN
        BEGIN
            RETURN to_tsvector(r, left(p_in, 100000));
        EXCEPTION WHEN others THEN
            RETURN null;
        END;
    END;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_group ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_group_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_permission ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


--
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_user_groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_user_user_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: automation_aiagentactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_aiagentactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_automation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_automation (
    application_ptr_id integer NOT NULL,
    published_from_id integer
);


--
-- Name: automation_automationnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_automationnode (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    content_type_id integer NOT NULL,
    workflow_id integer NOT NULL,
    service_id integer NOT NULL,
    label character varying(75) DEFAULT ''::character varying NOT NULL
);


--
-- Name: automation_automationnode_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.automation_automationnode ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.automation_automationnode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: automation_automationnodehistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_automationnodehistory (
    id integer NOT NULL,
    started_on timestamp with time zone NOT NULL,
    completed_on timestamp with time zone,
    message text NOT NULL,
    status character varying(8) NOT NULL,
    node_id integer NOT NULL,
    workflow_history_id integer NOT NULL
);


--
-- Name: automation_automationnodehistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.automation_automationnodehistory ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.automation_automationnodehistory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: automation_automationnoderesult; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_automationnoderesult (
    id integer NOT NULL,
    result jsonb DEFAULT '{}'::jsonb NOT NULL,
    node_history_id integer NOT NULL,
    iteration_path character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: automation_automationnoderesult_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.automation_automationnoderesult ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.automation_automationnoderesult_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: automation_automationworkflow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_automationworkflow (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    name character varying(255) NOT NULL,
    "order" integer NOT NULL,
    automation_id integer NOT NULL,
    allow_test_run_until timestamp with time zone,
    state character varying(20) DEFAULT 'draft'::character varying NOT NULL,
    simulate_until_node_id integer,
    graph jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT automation_automationworkflow_order_check CHECK (("order" >= 0))
);


--
-- Name: automation_automationworkflow_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.automation_automationworkflow ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.automation_automationworkflow_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: automation_automationworkflow_notification_recipients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_automationworkflow_notification_recipients (
    id integer NOT NULL,
    automationworkflow_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: automation_automationworkflow_notification_recipients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.automation_automationworkflow_notification_recipients ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.automation_automationworkflow_notification_recipients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: automation_automationworkflowhistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_automationworkflowhistory (
    id integer NOT NULL,
    started_on timestamp with time zone NOT NULL,
    completed_on timestamp with time zone,
    message text NOT NULL,
    is_test_run boolean DEFAULT false NOT NULL,
    status character varying(8) NOT NULL,
    workflow_id integer NOT NULL,
    event_payload jsonb DEFAULT 'null'::jsonb,
    simulate_until_node_id integer,
    original_workflow_id integer NOT NULL
);


--
-- Name: automation_automationworkflowhistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.automation_automationworkflowhistory ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.automation_automationworkflowhistory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: automation_corecsvfilereaderactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_corecsvfilereaderactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_corehttprequestactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_corehttprequestactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_corehttptriggernode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_corehttptriggernode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_coreiteratoractionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_coreiteratoractionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_coremanualtriggernode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_coremanualtriggernode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_coreperiodictriggernode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_coreperiodictriggernode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_corerouteractionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_corerouteractionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_coresmtpemailactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_coresmtpemailactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_corestartworkflowactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_corestartworkflowactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_duplicateautomationworkflowjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_duplicateautomationworkflowjob (
    job_ptr_id integer NOT NULL,
    user_ip_address inet,
    user_websocket_id character varying(36),
    user_session_id character varying(36),
    user_action_group_id character varying(36),
    duplicated_automation_workflow_id integer,
    original_automation_workflow_id integer
);


--
-- Name: automation_localbaserowaggregaterowsactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowaggregaterowsactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_localbaserowcreaterowactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowcreaterowactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_localbaserowcreaterowsactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowcreaterowsactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_localbaserowdeleterowactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowdeleterowactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_localbaserowfieldsupdatedtriggernode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowfieldsupdatedtriggernode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_localbaserowgetrowactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowgetrowactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_localbaserowlistrowsactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowlistrowsactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_localbaserowrowscreatedtriggernode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowrowscreatedtriggernode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_localbaserowrowsdeletedtriggernode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowrowsdeletedtriggernode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_localbaserowrowsupdatedtriggernode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowrowsupdatedtriggernode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_localbaserowupdaterowactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowupdaterowactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_localbaserowupdaterowsactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_localbaserowupdaterowsactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: automation_publishautomationworkflowjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_publishautomationworkflowjob (
    job_ptr_id integer NOT NULL,
    user_ip_address inet,
    automation_workflow_id integer
);


--
-- Name: automation_slackwritemessageactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.automation_slackwritemessageactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: baserow_enterprise_assistantchat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_assistantchat (
    id bigint NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    uuid uuid NOT NULL,
    title character varying(250) NOT NULL,
    status character varying(20) NOT NULL,
    user_id integer NOT NULL,
    workspace_id integer NOT NULL,
    message_history bytea
);


--
-- Name: baserow_enterprise_assistantchat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_assistantchat ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_assistantchat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_assistantchatmessage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_assistantchatmessage (
    id bigint NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    role character varying(10) NOT NULL,
    content text NOT NULL,
    artifacts jsonb NOT NULL,
    chat_id bigint NOT NULL,
    action_group_id uuid
);


--
-- Name: baserow_enterprise_assistantchatmessage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_assistantchatmessage ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_assistantchatmessage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_assistantchatprediction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_assistantchatprediction (
    id bigint NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    prediction jsonb NOT NULL,
    human_sentiment smallint,
    human_feedback text NOT NULL,
    ai_response_id bigint NOT NULL,
    human_message_id bigint NOT NULL
);


--
-- Name: baserow_enterprise_assistantchatprediction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_assistantchatprediction ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_assistantchatprediction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_auditlogentry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_auditlogentry (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    user_id integer,
    user_email character varying(254),
    workspace_id integer,
    workspace_name character varying(165),
    action_type text NOT NULL,
    action_timestamp timestamp with time zone NOT NULL,
    action_params jsonb,
    action_command_type character varying(5) NOT NULL,
    original_action_short_descr text,
    original_action_long_descr text,
    original_action_context_descr text,
    ip_address inet,
    action_uuid character varying(36),
    CONSTRAINT baserow_enterprise_auditlogentry_user_id_check CHECK ((user_id >= 0)),
    CONSTRAINT baserow_enterprise_auditlogentry_workspace_id_check CHECK ((workspace_id >= 0))
);


--
-- Name: baserow_enterprise_auditlogentry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_auditlogentry ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_auditlogentry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_auditlogexportjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_auditlogexportjob (
    job_ptr_id integer NOT NULL,
    export_charset character varying(32) NOT NULL,
    csv_column_separator character varying(32) NOT NULL,
    csv_first_row_header boolean NOT NULL,
    filter_user_id integer,
    filter_workspace_id integer,
    filter_action_type character varying(32),
    filter_from_timestamp timestamp with time zone,
    filter_to_timestamp timestamp with time zone,
    exported_file_name text,
    exclude_columns character varying(255),
    CONSTRAINT baserow_enterprise_auditlogexportjob_filter_group_id_check CHECK ((filter_workspace_id >= 0)),
    CONSTRAINT baserow_enterprise_auditlogexportjob_filter_user_id_check CHECK ((filter_user_id >= 0))
);


--
-- Name: baserow_enterprise_authformelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_authformelement (
    element_ptr_id integer NOT NULL,
    user_source_id integer,
    login_button_label text DEFAULT '{"f": "", "m": "simple", "v": "0.1"}'::text
);


--
-- Name: baserow_enterprise_buildercustomcode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_buildercustomcode (
    id integer NOT NULL,
    css text NOT NULL,
    js text NOT NULL,
    builder_id integer NOT NULL
);


--
-- Name: baserow_enterprise_buildercustomcode_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_buildercustomcode ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_buildercustomcode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_buildercustomscript; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_buildercustomscript (
    id integer NOT NULL,
    "order" integer NOT NULL,
    type character varying(20) NOT NULL,
    url character varying(200) NOT NULL,
    load_type character varying(10) NOT NULL,
    crossorigin character varying(20) NOT NULL,
    builder_id integer NOT NULL,
    CONSTRAINT baserow_enterprise_buildercustomscript_order_check CHECK (("order" >= 0))
);


--
-- Name: baserow_enterprise_buildercustomscript_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_buildercustomscript ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_buildercustomscript_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_corecodeactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_corecodeactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: baserow_enterprise_corecodeservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_corecodeservice (
    service_ptr_id integer NOT NULL,
    code text NOT NULL
);


--
-- Name: baserow_enterprise_corecodeserviceinjection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_corecodeserviceinjection (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    formula text,
    service_id integer NOT NULL
);


--
-- Name: baserow_enterprise_corecodeserviceinjection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_corecodeserviceinjection ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_corecodeserviceinjection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_corecodeworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_corecodeworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: baserow_enterprise_corexlsfilereaderactionnode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_corexlsfilereaderactionnode (
    automationnode_ptr_id integer NOT NULL
);


--
-- Name: baserow_enterprise_corexlsfilereaderservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_corexlsfilereaderservice (
    service_ptr_id integer NOT NULL,
    file text,
    sheet_name text,
    first_line_is_header boolean NOT NULL
);


--
-- Name: baserow_enterprise_corexlsfilereaderworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_corexlsfilereaderworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: baserow_enterprise_datascan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_datascan (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    scan_type character varying(20) NOT NULL,
    pattern text,
    frequency character varying(10) NOT NULL,
    scan_all_workspaces boolean NOT NULL,
    is_running boolean NOT NULL,
    last_run_started_at timestamp with time zone,
    last_run_finished_at timestamp with time zone,
    last_error text,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    created_by_id integer,
    source_field_id integer,
    source_table_id integer,
    whole_words boolean DEFAULT true NOT NULL
);


--
-- Name: baserow_enterprise_datascan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_datascan ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_datascan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_datascan_workspaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_datascan_workspaces (
    id integer NOT NULL,
    datascan_id integer NOT NULL,
    workspace_id integer NOT NULL
);


--
-- Name: baserow_enterprise_datascan_workspaces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_datascan_workspaces ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_datascan_workspaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_datascanlistitem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_datascanlistitem (
    id integer NOT NULL,
    value text NOT NULL,
    scan_id integer NOT NULL
);


--
-- Name: baserow_enterprise_datascanlistitem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_datascanlistitem ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_datascanlistitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_datascanresult; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_datascanresult (
    id integer NOT NULL,
    row_id integer NOT NULL,
    matched_value text NOT NULL,
    first_identified_on timestamp with time zone NOT NULL,
    last_identified_on timestamp with time zone NOT NULL,
    field_id integer NOT NULL,
    scan_id integer NOT NULL,
    table_id integer NOT NULL
);


--
-- Name: baserow_enterprise_datascanresult_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_datascanresult ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_datascanresult_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_datascanresultexportjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_datascanresultexportjob (
    job_ptr_id integer NOT NULL,
    export_charset character varying(32) NOT NULL,
    csv_column_separator character varying(32) NOT NULL,
    csv_first_row_header boolean NOT NULL,
    filter_scan_id integer,
    exported_file_name text,
    CONSTRAINT baserow_enterprise_datascanresultexportjob_filter_scan_id_check CHECK ((filter_scan_id >= 0))
);


--
-- Name: baserow_enterprise_datedependency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_datedependency (
    fieldrule_ptr_id integer NOT NULL,
    dependency_linkrow_role character varying,
    dependency_connection_type character varying,
    dependency_buffer_type character varying,
    dependency_buffer interval,
    include_weekends boolean NOT NULL,
    dependency_linkrow_field_id integer,
    duration_field_id integer,
    end_date_field_id integer,
    start_date_field_id integer
);


--
-- Name: baserow_enterprise_facebookauthprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_facebookauthprovidermodel (
    authprovidermodel_ptr_id integer NOT NULL,
    name character varying(255) NOT NULL,
    client_id character varying(191) NOT NULL,
    secret character varying(191) NOT NULL
);


--
-- Name: baserow_enterprise_fieldpermissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_fieldpermissions (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    role text NOT NULL,
    allow_in_forms boolean NOT NULL,
    field_id integer NOT NULL
);


--
-- Name: baserow_enterprise_fieldpermissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_fieldpermissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_fieldpermissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_fileinputelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_fileinputelement (
    element_ptr_id integer NOT NULL,
    required boolean NOT NULL,
    label text,
    default_name text,
    default_url text,
    help_text text,
    multiple boolean NOT NULL,
    max_filesize integer NOT NULL,
    allowed_filetypes jsonb NOT NULL,
    preview boolean NOT NULL,
    CONSTRAINT baserow_enterprise_fileinputelement_max_filesize_check CHECK ((max_filesize >= 0))
);


--
-- Name: baserow_enterprise_githubauthprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_githubauthprovidermodel (
    authprovidermodel_ptr_id integer NOT NULL,
    name character varying(255) NOT NULL,
    client_id character varying(191) NOT NULL,
    secret character varying(191) NOT NULL
);


--
-- Name: baserow_enterprise_githubissuesdatasync; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_githubissuesdatasync (
    datasync_ptr_id integer NOT NULL,
    github_issues_owner character varying(255) NOT NULL,
    github_issues_repo character varying(255) NOT NULL,
    github_issues_api_token character varying(255) NOT NULL
);


--
-- Name: baserow_enterprise_gitlabauthprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_gitlabauthprovidermodel (
    authprovidermodel_ptr_id integer NOT NULL,
    name character varying(255) NOT NULL,
    base_url character varying(200) NOT NULL,
    client_id character varying(191) NOT NULL,
    secret character varying(191) NOT NULL
);


--
-- Name: baserow_enterprise_gitlabissuesdatasync; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_gitlabissuesdatasync (
    datasync_ptr_id integer NOT NULL,
    gitlab_url character varying(2000) NOT NULL,
    gitlab_project_id character varying(255) NOT NULL,
    gitlab_access_token character varying(255) NOT NULL
);


--
-- Name: baserow_enterprise_googleauthprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_googleauthprovidermodel (
    authprovidermodel_ptr_id integer NOT NULL,
    name character varying(255) NOT NULL,
    client_id character varying(191) NOT NULL,
    secret character varying(191) NOT NULL
);


--
-- Name: baserow_enterprise_hubspotcontactsdatasync; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_hubspotcontactsdatasync (
    datasync_ptr_id integer NOT NULL,
    hubspot_access_token character varying(255) NOT NULL
);


--
-- Name: baserow_enterprise_jiraissuesdatasync; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_jiraissuesdatasync (
    datasync_ptr_id integer NOT NULL,
    jira_url character varying(2000) NOT NULL,
    jira_project_key character varying(255) NOT NULL,
    jira_username character varying(255) NOT NULL,
    jira_api_token character varying(255) NOT NULL,
    jira_authentication character varying DEFAULT 'API_TOKEN'::character varying NOT NULL
);


--
-- Name: baserow_enterprise_knowledgebasecategory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_knowledgebasecategory (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    parent_id integer
);


--
-- Name: baserow_enterprise_knowledgebasecategory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_knowledgebasecategory ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_knowledgebasecategory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_knowledgebasechunk; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_knowledgebasechunk (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    _embedding_array double precision[],
    index integer NOT NULL,
    content text NOT NULL,
    metadata jsonb NOT NULL,
    source_document_id integer NOT NULL,
    CONSTRAINT baserow_enterprise_knowledgebasechunk_index_check CHECK ((index >= 0))
);


--
-- Name: baserow_enterprise_knowledgebasechunk_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_knowledgebasechunk ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_knowledgebasechunk_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_knowledgebasedocument; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_knowledgebasedocument (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    title character varying(250) NOT NULL,
    slug character varying(255) NOT NULL,
    source_url character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    raw_content text NOT NULL,
    process_document boolean NOT NULL,
    content text NOT NULL,
    status character varying(20) NOT NULL,
    category_id integer
);


--
-- Name: baserow_enterprise_knowledgebasedocument_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_knowledgebasedocument ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_knowledgebasedocument_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_localbaserowpasswordappauthprovider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_localbaserowpasswordappauthprovider (
    appauthprovider_ptr_id integer NOT NULL,
    password_field_id integer
);


--
-- Name: baserow_enterprise_localbaserowtabledatasync; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_localbaserowtabledatasync (
    datasync_ptr_id integer NOT NULL,
    authorized_user_id integer,
    source_table_id integer,
    source_table_view_id integer,
    CONSTRAINT baserow_enterprise_localbaserowtable_source_table_view_id_check CHECK ((source_table_view_id >= 0))
);


--
-- Name: baserow_premium_localbaserowtableserviceaggregationgroupby; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_localbaserowtableserviceaggregationgroupby (
    id integer NOT NULL,
    "order" integer NOT NULL,
    field_id integer,
    service_id integer NOT NULL,
    CONSTRAINT baserow_enterprise_localbaserowtableserviceaggregat_order_check CHECK (("order" >= 0))
);


--
-- Name: baserow_enterprise_localbaserowtableserviceaggregationgr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_premium_localbaserowtableserviceaggregationgroupby ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_localbaserowtableserviceaggregationgr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_premium_localbaserowtableserviceaggregationseries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_localbaserowtableserviceaggregationseries (
    id integer NOT NULL,
    aggregation_type character varying(48) NOT NULL,
    "order" integer NOT NULL,
    field_id integer,
    service_id integer NOT NULL,
    CONSTRAINT baserow_enterprise_localbaserowtableserviceaggrega_order_check1 CHECK (("order" >= 0))
);


--
-- Name: baserow_enterprise_localbaserowtableserviceaggregationse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_premium_localbaserowtableserviceaggregationseries ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_localbaserowtableserviceaggregationse_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_premium_localbaserowtableserviceaggregationsortby; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_localbaserowtableserviceaggregationsortby (
    id integer NOT NULL,
    sort_on character varying(255) NOT NULL,
    reference character varying(255) NOT NULL,
    direction character varying(255) NOT NULL,
    "order" integer NOT NULL,
    service_id integer NOT NULL,
    CONSTRAINT baserow_enterprise_localbaserowtableserviceaggrega_order_check2 CHECK (("order" >= 0))
);


--
-- Name: baserow_enterprise_localbaserowtableserviceaggregationso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_premium_localbaserowtableserviceaggregationsortby ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_localbaserowtableserviceaggregationso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_localbaserowusersource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_localbaserowusersource (
    usersource_ptr_id integer NOT NULL,
    email_field_id integer,
    name_field_id integer,
    table_id integer,
    role_field_id integer
);


--
-- Name: baserow_enterprise_openidconnectappauthprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_openidconnectappauthprovidermodel (
    appauthprovider_ptr_id integer NOT NULL,
    name character varying(255) NOT NULL,
    base_url character varying(200) NOT NULL,
    client_id character varying(191) NOT NULL,
    secret character varying(191) NOT NULL,
    authorization_url character varying(200) NOT NULL,
    access_token_url character varying(200) NOT NULL,
    user_info_url character varying(200) NOT NULL,
    email_attr_key character varying(32) DEFAULT 'email'::character varying NOT NULL,
    first_name_attr_key character varying(32) DEFAULT 'name'::character varying NOT NULL,
    issuer character varying(200) DEFAULT ''::character varying NOT NULL,
    jwks_url character varying(200) DEFAULT ''::character varying NOT NULL,
    last_name_attr_key character varying(32) DEFAULT ''::character varying NOT NULL,
    use_id_token boolean DEFAULT false NOT NULL
);


--
-- Name: baserow_enterprise_openidconnectauthprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_openidconnectauthprovidermodel (
    authprovidermodel_ptr_id integer NOT NULL,
    name character varying(255) NOT NULL,
    base_url character varying(200) NOT NULL,
    client_id character varying(191) NOT NULL,
    secret character varying(191) NOT NULL,
    authorization_url character varying(200) NOT NULL,
    access_token_url character varying(200) NOT NULL,
    user_info_url character varying(200) NOT NULL,
    email_attr_key character varying(32) DEFAULT 'email'::character varying NOT NULL,
    first_name_attr_key character varying(32) DEFAULT 'name'::character varying NOT NULL,
    issuer character varying(200) DEFAULT ''::character varying NOT NULL,
    jwks_url character varying(200) DEFAULT ''::character varying NOT NULL,
    last_name_attr_key character varying(32) DEFAULT ''::character varying NOT NULL,
    use_id_token boolean DEFAULT false NOT NULL
);


--
-- Name: baserow_enterprise_periodicdatasyncinterval; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_periodicdatasyncinterval (
    id integer NOT NULL,
    last_periodic_sync timestamp with time zone,
    "interval" character varying NOT NULL,
    "when" time without time zone NOT NULL,
    automatically_deactivated boolean NOT NULL,
    consecutive_failed_count smallint NOT NULL,
    authorized_user_id integer,
    data_sync_id integer NOT NULL,
    deactivation_reason character varying(20)
);


--
-- Name: baserow_enterprise_periodicdatasyncinterval_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_periodicdatasyncinterval ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_periodicdatasyncinterval_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_role (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    uid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    "default" boolean NOT NULL,
    workspace_id integer,
    hidden boolean DEFAULT false NOT NULL
);


--
-- Name: baserow_enterprise_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_role ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_role_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_role_operations (
    id integer NOT NULL,
    role_id integer NOT NULL,
    operation_id integer NOT NULL
);


--
-- Name: baserow_enterprise_role_operations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_role_operations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_role_operations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_roleassignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_roleassignment (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    subject_id integer NOT NULL,
    scope_id integer NOT NULL,
    workspace_id integer NOT NULL,
    role_id integer NOT NULL,
    scope_type_id integer NOT NULL,
    subject_type_id integer NOT NULL
);


--
-- Name: baserow_enterprise_roleassignment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_roleassignment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_roleassignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_samlappauthprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_samlappauthprovidermodel (
    appauthprovider_ptr_id integer NOT NULL,
    metadata text NOT NULL,
    is_verified boolean NOT NULL,
    email_attr_key character varying(32) DEFAULT 'user.email'::character varying NOT NULL,
    first_name_attr_key character varying(32) DEFAULT 'user.first_name'::character varying NOT NULL,
    last_name_attr_key character varying(32) DEFAULT 'user.last_name'::character varying NOT NULL
);


--
-- Name: baserow_enterprise_samlauthprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_samlauthprovidermodel (
    authprovidermodel_ptr_id integer NOT NULL,
    metadata text NOT NULL,
    is_verified boolean NOT NULL,
    email_attr_key character varying(32) DEFAULT 'user.email'::character varying NOT NULL,
    first_name_attr_key character varying(32) DEFAULT 'user.first_name'::character varying NOT NULL,
    last_name_attr_key character varying(32) DEFAULT 'user.last_name'::character varying NOT NULL
);


--
-- Name: baserow_enterprise_team; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_team (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    name character varying(160) NOT NULL,
    workspace_id integer NOT NULL
);


--
-- Name: baserow_enterprise_team_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_team ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_team_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_enterprise_teamsubject; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_enterprise_teamsubject (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    subject_id integer NOT NULL,
    subject_type_id integer NOT NULL,
    team_id integer NOT NULL
);


--
-- Name: baserow_enterprise_teamsubject_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_enterprise_teamsubject ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_enterprise_teamsubject_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_premium_aifield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_aifield (
    field_ptr_id integer NOT NULL,
    ai_generative_ai_type character varying(32),
    ai_generative_ai_model character varying(128),
    ai_prompt text,
    ai_file_field_id integer,
    ai_temperature double precision,
    ai_output_type character varying(32) DEFAULT 'text'::character varying NOT NULL,
    ai_auto_update boolean DEFAULT false NOT NULL,
    ai_auto_update_user_id integer
);


--
-- Name: baserow_premium_aifieldscheduledupdate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_aifieldscheduledupdate (
    id bigint NOT NULL,
    field_id integer NOT NULL,
    row_id integer NOT NULL,
    updated_on timestamp with time zone NOT NULL
);


--
-- Name: baserow_premium_aifieldscheduledupdate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_premium_aifieldscheduledupdate ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_premium_aifieldscheduledupdate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_premium_chartseriesconfig; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_chartseriesconfig (
    id integer NOT NULL,
    series_chart_type character varying(4) NOT NULL,
    series_id integer NOT NULL,
    widget_id integer NOT NULL
);


--
-- Name: baserow_premium_chartseriesconfig_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_premium_chartseriesconfig ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_premium_chartseriesconfig_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_premium_chartwidget; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_chartwidget (
    widget_ptr_id integer NOT NULL,
    data_source_id integer NOT NULL,
    default_series_chart_type character varying(4) DEFAULT 'BAR'::character varying NOT NULL
);


--
-- Name: baserow_premium_generateaivaluesjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_generateaivaluesjob (
    job_ptr_id integer NOT NULL,
    user_ip_address inet,
    user_websocket_id character varying(36),
    user_session_id character varying(36),
    user_action_group_id character varying(36),
    row_ids integer[],
    view_id integer,
    only_empty boolean NOT NULL,
    field_id integer NOT NULL,
    is_auto_update boolean DEFAULT false
);


--
-- Name: baserow_premium_license; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_license (
    id integer NOT NULL,
    license text NOT NULL,
    last_check timestamp with time zone,
    cached_untrusted_instance_wide boolean NOT NULL
);


--
-- Name: baserow_premium_license_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_premium_license ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_premium_license_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_premium_licenseuser; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_licenseuser (
    id integer NOT NULL,
    license_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: baserow_premium_licenseuser_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_premium_licenseuser ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_premium_licenseuser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_premium_localbaserowgroupedaggregaterows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_localbaserowgroupedaggregaterows (
    service_ptr_id integer NOT NULL,
    filter_type character varying(3) NOT NULL,
    table_id integer,
    view_id integer
);


--
-- Name: baserow_premium_piechartseriesconfig; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_piechartseriesconfig (
    id integer NOT NULL,
    series_chart_type character varying(10) NOT NULL,
    series_id integer NOT NULL,
    widget_id integer NOT NULL
);


--
-- Name: baserow_premium_piechartseriesconfig_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_premium_piechartseriesconfig ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_premium_piechartseriesconfig_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: baserow_premium_piechartwidget; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_piechartwidget (
    widget_ptr_id integer NOT NULL,
    default_series_chart_type character varying(10) DEFAULT 'PIE'::character varying NOT NULL,
    data_source_id integer NOT NULL
);


--
-- Name: baserow_premium_rowcommentsnotificationmode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.baserow_premium_rowcommentsnotificationmode (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    row_id integer NOT NULL,
    mode character varying(32) NOT NULL,
    table_id integer NOT NULL,
    user_id integer,
    CONSTRAINT baserow_premium_rowcommentsnotificationmode_row_id_check CHECK ((row_id >= 0))
);


--
-- Name: baserow_premium_rowcommentsnotificationmode_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.baserow_premium_rowcommentsnotificationmode ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.baserow_premium_rowcommentsnotificationmode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_aiagentworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_aiagentworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: builder_builder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_builder (
    application_ptr_id integer NOT NULL,
    favicon_file_id integer,
    login_page_id integer
);


--
-- Name: builder_builderworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_builderworkflowaction (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    event character varying(60) NOT NULL,
    content_type_id integer NOT NULL,
    element_id integer,
    page_id integer NOT NULL,
    "order" integer NOT NULL,
    CONSTRAINT builder_builderworkflowaction_order_check CHECK (("order" >= 0))
);


--
-- Name: builder_builderworkflowaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_builderworkflowaction ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_builderworkflowaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_buttonelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_buttonelement (
    element_ptr_id integer NOT NULL,
    value text
);


--
-- Name: builder_buttonthemeconfigblock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_buttonthemeconfigblock (
    id integer NOT NULL,
    button_background_color character varying(255) NOT NULL,
    button_hover_background_color character varying(255) NOT NULL,
    builder_id integer NOT NULL,
    button_alignment character varying(10) NOT NULL,
    button_text_alignment character varying(10) NOT NULL,
    button_width character varying(10) NOT NULL,
    button_border_color character varying(255) NOT NULL,
    button_border_radius smallint NOT NULL,
    button_border_size smallint NOT NULL,
    button_font_family character varying(250) NOT NULL,
    button_font_size smallint NOT NULL,
    button_horizontal_padding smallint NOT NULL,
    button_hover_border_color character varying(255) NOT NULL,
    button_hover_text_color character varying(255) NOT NULL,
    button_text_color character varying(255) NOT NULL,
    button_vertical_padding smallint NOT NULL,
    button_font_weight character varying(11) DEFAULT 'regular'::character varying NOT NULL,
    button_active_background_color character varying(255) NOT NULL,
    button_active_border_color character varying(255) NOT NULL,
    button_active_text_color character varying(255) NOT NULL
);


--
-- Name: builder_buttonthemeconfigblock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_buttonthemeconfigblock ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_buttonthemeconfigblock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_checkboxelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_checkboxelement (
    element_ptr_id integer NOT NULL,
    label text,
    default_value text,
    required boolean NOT NULL
);


--
-- Name: builder_choiceelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_choiceelement (
    element_ptr_id integer NOT NULL,
    label text,
    default_value text,
    required boolean NOT NULL,
    placeholder text,
    multiple boolean NOT NULL,
    show_as_dropdown boolean NOT NULL,
    formula_name text,
    formula_value text,
    option_type character varying(32) NOT NULL
);


--
-- Name: builder_choiceelementoption; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_choiceelementoption (
    id integer NOT NULL,
    value text,
    name text NOT NULL,
    choice_id integer NOT NULL
);


--
-- Name: builder_collectionelementpropertyoptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_collectionelementpropertyoptions (
    id integer NOT NULL,
    schema_property character varying(225) NOT NULL,
    searchable boolean NOT NULL,
    filterable boolean NOT NULL,
    sortable boolean NOT NULL,
    element_id integer NOT NULL
);


--
-- Name: builder_collectionelementpropertyoptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_collectionelementpropertyoptions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_collectionelementpropertyoptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_collectionfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_collectionfield (
    id integer NOT NULL,
    "order" integer NOT NULL,
    name character varying(225) NOT NULL,
    type character varying(225) NOT NULL,
    config jsonb NOT NULL,
    uid uuid NOT NULL,
    styles jsonb,
    CONSTRAINT builder_collectionfield_order_check CHECK (("order" >= 0))
);


--
-- Name: builder_collectionfield_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_collectionfield ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_collectionfield_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_colorthemeconfigblock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_colorthemeconfigblock (
    id integer NOT NULL,
    primary_color character varying(255) NOT NULL,
    secondary_color character varying(255) NOT NULL,
    border_color character varying(255) NOT NULL,
    builder_id integer NOT NULL,
    main_error_color character varying(255) NOT NULL,
    main_success_color character varying(255) NOT NULL,
    main_warning_color character varying(255) NOT NULL,
    custom_colors jsonb DEFAULT '[]'::jsonb NOT NULL
);


--
-- Name: builder_colorthemeconfigblock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_colorthemeconfigblock ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_colorthemeconfigblock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_columnelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_columnelement (
    element_ptr_id integer NOT NULL,
    column_amount integer NOT NULL,
    column_gap integer NOT NULL,
    alignment character varying(10) NOT NULL,
    layout_type character varying(20) DEFAULT 'auto'::character varying NOT NULL,
    column_weights jsonb DEFAULT '[]'::jsonb NOT NULL,
    column_stacking jsonb DEFAULT '{"tablet": "horizontal", "desktop": "horizontal", "smartphone": "stacked"}'::jsonb NOT NULL
);


--
-- Name: builder_corecsvfilereaderworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_corecsvfilereaderworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: builder_corehttprequestworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_corehttprequestworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: builder_coresmtpemailworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_coresmtpemailworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: builder_corestartworkflowworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_corestartworkflowworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: builder_customdomain; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_customdomain (
    domain_ptr_id integer NOT NULL
);


--
-- Name: builder_datasource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_datasource (
    id integer NOT NULL,
    trashed boolean NOT NULL,
    name character varying(255) NOT NULL,
    "order" numeric(40,20) NOT NULL,
    page_id integer NOT NULL,
    service_id integer
);


--
-- Name: builder_datasource_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_datasource ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_datetimepickerelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_datetimepickerelement (
    element_ptr_id integer NOT NULL,
    required boolean NOT NULL,
    label text,
    default_value text,
    date_format character varying(32) NOT NULL,
    include_time boolean NOT NULL,
    time_format character varying(32) NOT NULL
);


--
-- Name: builder_domain; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_domain (
    id integer NOT NULL,
    trashed boolean NOT NULL,
    "order" integer NOT NULL,
    domain_name character varying(255) NOT NULL,
    builder_id integer NOT NULL,
    last_published timestamp with time zone,
    published_to_id integer,
    content_type_id integer NOT NULL,
    CONSTRAINT builder_domain_order_check CHECK (("order" >= 0))
);


--
-- Name: builder_domain_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_domain ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_domain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_dropdownelementoption_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_choiceelementoption ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_dropdownelementoption_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_duplicatepagejob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_duplicatepagejob (
    job_ptr_id integer NOT NULL,
    user_ip_address inet,
    user_websocket_id character varying(36),
    user_session_id character varying(36),
    user_action_group_id character varying(36),
    duplicated_page_id integer,
    original_page_id integer
);


--
-- Name: builder_element; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_element (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    "order" numeric(40,20) NOT NULL,
    content_type_id integer NOT NULL,
    page_id integer NOT NULL,
    style_padding_bottom integer NOT NULL,
    style_padding_top integer NOT NULL,
    parent_element_id integer,
    place_in_container character varying(255),
    style_background character varying(20) NOT NULL,
    style_background_color character varying(255) NOT NULL,
    style_border_bottom_color character varying(255) NOT NULL,
    style_border_bottom_size integer NOT NULL,
    style_border_top_color character varying(255) NOT NULL,
    style_border_top_size integer NOT NULL,
    style_width character varying(20) NOT NULL,
    style_border_left_color character varying(255) NOT NULL,
    style_border_left_size integer NOT NULL,
    style_border_right_color character varying(255) NOT NULL,
    style_border_right_size integer NOT NULL,
    style_padding_left integer NOT NULL,
    style_padding_right integer NOT NULL,
    visibility character varying(20) NOT NULL,
    role_type character varying(19) NOT NULL,
    roles jsonb NOT NULL,
    styles jsonb NOT NULL,
    style_background_file_id integer,
    style_background_mode character varying(32) NOT NULL,
    style_margin_bottom integer NOT NULL,
    style_margin_left integer NOT NULL,
    style_margin_right integer NOT NULL,
    style_margin_top integer NOT NULL,
    style_background_radius smallint DEFAULT 0 NOT NULL,
    style_border_radius smallint DEFAULT 0 NOT NULL,
    style_width_child character varying(6) DEFAULT 'normal'::character varying NOT NULL,
    css_classes character varying(255) DEFAULT ''::character varying NOT NULL,
    visibility_condition text,
    CONSTRAINT builder_element_style_border_bottom_size_check CHECK ((style_border_bottom_size >= 0)),
    CONSTRAINT builder_element_style_border_left_size_check CHECK ((style_border_left_size >= 0)),
    CONSTRAINT builder_element_style_border_right_size_check CHECK ((style_border_right_size >= 0)),
    CONSTRAINT builder_element_style_border_top_size_check CHECK ((style_border_top_size >= 0)),
    CONSTRAINT builder_element_style_margin_bottom_check CHECK ((style_margin_bottom >= 0)),
    CONSTRAINT builder_element_style_margin_left_check CHECK ((style_margin_left >= 0)),
    CONSTRAINT builder_element_style_margin_right_check CHECK ((style_margin_right >= 0)),
    CONSTRAINT builder_element_style_margin_top_check CHECK ((style_margin_top >= 0)),
    CONSTRAINT builder_element_style_padding_bottom_check CHECK ((style_padding_bottom >= 0)),
    CONSTRAINT builder_element_style_padding_left_check CHECK ((style_padding_left >= 0)),
    CONSTRAINT builder_element_style_padding_right_check CHECK ((style_padding_right >= 0)),
    CONSTRAINT builder_element_style_padding_top_check CHECK ((style_padding_top >= 0))
);


--
-- Name: builder_element_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_element ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_element_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_footerelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_footerelement (
    element_ptr_id integer NOT NULL,
    share_type character varying(10) NOT NULL,
    behaviour character varying(15) DEFAULT 'normal'::character varying NOT NULL
);


--
-- Name: builder_footerelement_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_footerelement_pages (
    id integer NOT NULL,
    footerelement_id integer NOT NULL,
    page_id integer NOT NULL
);


--
-- Name: builder_footerelement_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_footerelement_pages ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_footerelement_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_formcontainerelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_formcontainerelement (
    element_ptr_id integer NOT NULL,
    submit_button_label text,
    reset_initial_values_post_submission boolean NOT NULL
);


--
-- Name: builder_headerelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_headerelement (
    element_ptr_id integer NOT NULL,
    share_type character varying(10) NOT NULL,
    behaviour character varying(15) DEFAULT 'normal'::character varying NOT NULL
);


--
-- Name: builder_headerelement_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_headerelement_pages (
    id integer NOT NULL,
    headerelement_id integer NOT NULL,
    page_id integer NOT NULL
);


--
-- Name: builder_headerelement_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_headerelement_pages ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_headerelement_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_headingelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_headingelement (
    element_ptr_id integer NOT NULL,
    value text,
    level integer NOT NULL
);


--
-- Name: builder_iframeelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_iframeelement (
    element_ptr_id integer NOT NULL,
    source_type character varying(32) NOT NULL,
    url text,
    embed text,
    height integer NOT NULL,
    CONSTRAINT builder_iframeelement_height_check CHECK ((height >= 0))
);


--
-- Name: builder_imageelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_imageelement (
    element_ptr_id integer NOT NULL,
    image_source_type character varying(32) NOT NULL,
    image_url text,
    alt_text text,
    image_file_id integer
);


--
-- Name: builder_imagethemeconfigblock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_imagethemeconfigblock (
    id integer NOT NULL,
    image_alignment character varying(10) NOT NULL,
    image_max_width integer NOT NULL,
    image_max_height integer,
    image_constraint character varying(32) NOT NULL,
    builder_id integer NOT NULL,
    image_border_radius smallint DEFAULT 0 NOT NULL,
    CONSTRAINT builder_imagethemeconfigblock_image_max_height_check CHECK ((image_max_height >= 0)),
    CONSTRAINT builder_imagethemeconfigblock_image_max_width_check CHECK ((image_max_width >= 0))
);


--
-- Name: builder_imagethemeconfigblock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_imagethemeconfigblock ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_imagethemeconfigblock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_inputtextelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_inputtextelement (
    element_ptr_id integer NOT NULL,
    default_value text,
    required boolean NOT NULL,
    placeholder text,
    label text,
    is_multiline boolean NOT NULL,
    rows integer NOT NULL,
    validation_type character varying(15) NOT NULL,
    input_type character varying(10) NOT NULL,
    CONSTRAINT builder_inputtextelement_rows_check CHECK ((rows >= 0))
);


--
-- Name: builder_inputthemeconfigblock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_inputthemeconfigblock (
    id integer NOT NULL,
    label_font_family character varying(250) NOT NULL,
    label_text_color character varying(255) NOT NULL,
    label_font_size smallint NOT NULL,
    input_font_family character varying(250) NOT NULL,
    input_font_size smallint NOT NULL,
    input_text_color character varying(255) NOT NULL,
    input_background_color character varying(255) NOT NULL,
    input_border_color character varying(255) NOT NULL,
    input_border_size smallint NOT NULL,
    input_border_radius smallint NOT NULL,
    input_vertical_padding smallint NOT NULL,
    input_horizontal_padding smallint NOT NULL,
    builder_id integer NOT NULL,
    input_font_weight character varying(11) DEFAULT 'regular'::character varying NOT NULL,
    label_font_weight character varying(11) DEFAULT 'medium'::character varying NOT NULL
);


--
-- Name: builder_inputthemeconfigblock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_inputthemeconfigblock ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_inputthemeconfigblock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_linkelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_linkelement (
    element_ptr_id integer NOT NULL,
    value text,
    navigation_type character varying(10),
    navigate_to_url text,
    page_parameters jsonb,
    variant character varying(10) NOT NULL,
    target character varying(10),
    navigate_to_page_id integer,
    query_parameters jsonb DEFAULT '[]'::jsonb
);


--
-- Name: builder_linkthemeconfigblock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_linkthemeconfigblock (
    id integer NOT NULL,
    link_text_alignment character varying(10) NOT NULL,
    link_text_color character varying(255) NOT NULL,
    link_hover_text_color character varying(255) NOT NULL,
    builder_id integer NOT NULL,
    link_font_family character varying(250) NOT NULL,
    link_font_size smallint NOT NULL,
    link_font_weight character varying(11) DEFAULT 'regular'::character varying NOT NULL,
    link_active_text_color character varying(255) NOT NULL,
    link_active_text_decoration character varying(4) DEFAULT '1000'::character varying NOT NULL,
    link_default_text_decoration character varying(4) DEFAULT '1000'::character varying NOT NULL,
    link_hover_text_decoration character varying(4) DEFAULT '1000'::character varying NOT NULL
);


--
-- Name: builder_linkthemeconfigblock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_linkthemeconfigblock ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_linkthemeconfigblock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_localbaserowcreaterowsworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_localbaserowcreaterowsworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: builder_localbaserowcreaterowworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_localbaserowcreaterowworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: builder_localbaserowdeleterowworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_localbaserowdeleterowworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: builder_localbaserowupdaterowsworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_localbaserowupdaterowsworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: builder_localbaserowupdaterowworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_localbaserowupdaterowworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: builder_logoutworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_logoutworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL
);


--
-- Name: builder_menuelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_menuelement (
    element_ptr_id integer NOT NULL,
    orientation character varying(10) DEFAULT 'horizontal'::character varying NOT NULL,
    alignment character varying(10) NOT NULL,
    variant jsonb DEFAULT '{"tablet": "compact", "desktop": "expanded", "smartphone": "compact"}'::jsonb NOT NULL
);


--
-- Name: builder_menuelement_menu_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_menuelement_menu_items (
    id integer NOT NULL,
    menuelement_id integer NOT NULL,
    menuitemelement_id integer NOT NULL
);


--
-- Name: builder_menuelement_menu_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_menuelement_menu_items ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_menuelement_menu_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_menuitemelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_menuitemelement (
    id integer NOT NULL,
    navigation_type character varying(10),
    navigate_to_url text,
    page_parameters jsonb,
    query_parameters jsonb DEFAULT '[]'::jsonb,
    target character varying(10),
    variant character varying(10) NOT NULL,
    type character varying(9) NOT NULL,
    name character varying(225) NOT NULL,
    menu_item_order integer NOT NULL,
    uid uuid NOT NULL,
    navigate_to_page_id integer,
    parent_menu_item_id integer,
    CONSTRAINT builder_menuitemelement_menu_item_order_check CHECK ((menu_item_order >= 0))
);


--
-- Name: builder_menuitemelement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_menuitemelement ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_menuitemelement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_notificationworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_notificationworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    title text,
    description text
);


--
-- Name: builder_openpageworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_openpageworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    navigate_to_page_id integer,
    navigate_to_url text,
    navigation_type character varying(10),
    page_parameters jsonb,
    target character varying(10),
    query_parameters jsonb DEFAULT '[]'::jsonb
);


--
-- Name: builder_page; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_page (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    "order" integer NOT NULL,
    name character varying(255) NOT NULL,
    builder_id integer NOT NULL,
    path character varying(255) NOT NULL,
    path_params jsonb NOT NULL,
    shared boolean DEFAULT false NOT NULL,
    role_type character varying(19) DEFAULT 'allow_all'::character varying NOT NULL,
    roles jsonb DEFAULT '[]'::jsonb NOT NULL,
    visibility character varying(20) DEFAULT 'all'::character varying NOT NULL,
    query_params jsonb DEFAULT '[]'::jsonb NOT NULL,
    graph jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT builder_page_order_check CHECK (("order" >= 0))
);


--
-- Name: builder_page_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_page ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_page_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_pagethemeconfigblock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_pagethemeconfigblock (
    id integer NOT NULL,
    page_background_color character varying(255) NOT NULL,
    page_background_mode character varying(32) NOT NULL,
    builder_id integer NOT NULL,
    page_background_file_id integer
);


--
-- Name: builder_pagethemeconfigblock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_pagethemeconfigblock ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_pagethemeconfigblock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_publishdomainjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_publishdomainjob (
    job_ptr_id integer NOT NULL,
    user_ip_address inet,
    domain_id integer
);


--
-- Name: builder_ratingelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_ratingelement (
    element_ptr_id integer NOT NULL,
    value text,
    max_value smallint NOT NULL,
    color character varying(50) NOT NULL,
    rating_style character varying(50) NOT NULL,
    CONSTRAINT builder_ratingelement_max_value_check CHECK ((max_value >= 0))
);


--
-- Name: builder_ratinginputelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_ratinginputelement (
    element_ptr_id integer NOT NULL,
    required boolean NOT NULL,
    value text,
    max_value smallint NOT NULL,
    color character varying(50) NOT NULL,
    rating_style character varying(50) NOT NULL,
    label text,
    CONSTRAINT builder_ratinginputelement_max_value_check CHECK ((max_value >= 0))
);


--
-- Name: builder_recordselectorelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_recordselectorelement (
    element_ptr_id integer NOT NULL,
    required boolean NOT NULL,
    schema_property character varying(225),
    items_per_page integer NOT NULL,
    button_load_more_label text,
    label text,
    default_value text,
    placeholder text,
    multiple boolean NOT NULL,
    option_name_suffix text,
    data_source_id integer,
    CONSTRAINT builder_recordselectorelement_items_per_page_check CHECK ((items_per_page >= 0))
);


--
-- Name: builder_refreshdatasourceworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_refreshdatasourceworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    data_source_id integer
);


--
-- Name: builder_repeatelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_repeatelement (
    element_ptr_id integer NOT NULL,
    items_per_page integer NOT NULL,
    data_source_id integer,
    items_per_row jsonb NOT NULL,
    orientation character varying(10) NOT NULL,
    button_load_more_label text,
    schema_property character varying(225),
    horizontal_gap integer DEFAULT 0 NOT NULL,
    vertical_gap integer DEFAULT 0 NOT NULL,
    CONSTRAINT builder_repeatelement_items_per_page_check CHECK ((items_per_page >= 0))
);


--
-- Name: builder_simplecontainerelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_simplecontainerelement (
    element_ptr_id integer NOT NULL
);


--
-- Name: builder_slackwritemessageworkflowaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_slackwritemessageworkflowaction (
    builderworkflowaction_ptr_id integer NOT NULL,
    service_id integer NOT NULL
);


--
-- Name: builder_subdomain; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_subdomain (
    domain_ptr_id integer NOT NULL
);


--
-- Name: builder_tableelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_tableelement (
    element_ptr_id integer NOT NULL,
    data_source_id integer,
    items_per_page integer NOT NULL,
    orientation jsonb,
    button_load_more_label text,
    schema_property character varying(225),
    CONSTRAINT builder_tableelement_items_per_page_check CHECK ((items_per_page >= 0))
);


--
-- Name: builder_tableelement_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_tableelement_fields (
    id integer NOT NULL,
    tableelement_id integer NOT NULL,
    collectionfield_id integer NOT NULL
);


--
-- Name: builder_tableelement_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_tableelement_fields ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_tableelement_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_tablethemeconfigblock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_tablethemeconfigblock (
    id integer NOT NULL,
    table_border_color character varying(255) NOT NULL,
    table_border_size smallint NOT NULL,
    table_border_radius smallint NOT NULL,
    table_header_background_color character varying(255) NOT NULL,
    table_header_text_color character varying(255) NOT NULL,
    table_header_font_size smallint NOT NULL,
    table_header_font_family character varying(250) NOT NULL,
    table_header_text_alignment character varying(10) NOT NULL,
    table_cell_background_color character varying(255) NOT NULL,
    table_cell_alternate_background_color character varying(255) NOT NULL,
    table_cell_alignment character varying(10) NOT NULL,
    table_cell_vertical_padding smallint NOT NULL,
    table_cell_horizontal_padding smallint NOT NULL,
    table_vertical_separator_color character varying(255) NOT NULL,
    table_vertical_separator_size smallint NOT NULL,
    table_horizontal_separator_color character varying(255) NOT NULL,
    table_horizontal_separator_size smallint NOT NULL,
    builder_id integer NOT NULL,
    table_header_font_weight character varying(11) DEFAULT 'semi-bold'::character varying NOT NULL
);


--
-- Name: builder_tablethemeconfigblock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_tablethemeconfigblock ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_tablethemeconfigblock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: builder_textelement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_textelement (
    element_ptr_id integer NOT NULL,
    value text,
    format character varying(10) NOT NULL
);


--
-- Name: builder_typographythemeconfigblock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builder_typographythemeconfigblock (
    id integer NOT NULL,
    heading_1_font_size smallint NOT NULL,
    heading_1_text_color character varying(255) NOT NULL,
    heading_2_font_size smallint NOT NULL,
    heading_2_text_color character varying(255) NOT NULL,
    heading_3_font_size smallint NOT NULL,
    heading_3_text_color character varying(255) NOT NULL,
    builder_id integer NOT NULL,
    body_text_color character varying(255) NOT NULL,
    body_font_size smallint NOT NULL,
    body_text_alignment character varying(10) NOT NULL,
    heading_1_text_alignment character varying(10) NOT NULL,
    heading_2_text_alignment character varying(10) NOT NULL,
    heading_3_text_alignment character varying(10) NOT NULL,
    heading_4_text_color character varying(255) NOT NULL,
    heading_4_font_size smallint NOT NULL,
    heading_4_text_alignment character varying(10) NOT NULL,
    heading_5_text_color character varying(255) NOT NULL,
    heading_5_font_size smallint NOT NULL,
    heading_5_text_alignment character varying(10) NOT NULL,
    heading_6_text_color character varying(255) NOT NULL,
    heading_6_font_size smallint NOT NULL,
    heading_6_text_alignment character varying(10) NOT NULL,
    body_font_family character varying(250) NOT NULL,
    heading_1_font_family character varying(250) NOT NULL,
    heading_2_font_family character varying(250) NOT NULL,
    heading_3_font_family character varying(250) NOT NULL,
    heading_4_font_family character varying(250) NOT NULL,
    heading_5_font_family character varying(250) NOT NULL,
    heading_6_font_family character varying(250) NOT NULL,
    body_font_weight character varying(11) DEFAULT 'regular'::character varying NOT NULL,
    heading_1_font_weight character varying(11) DEFAULT 'bold'::character varying NOT NULL,
    heading_2_font_weight character varying(11) DEFAULT 'semi-bold'::character varying NOT NULL,
    heading_3_font_weight character varying(11) DEFAULT 'medium'::character varying NOT NULL,
    heading_4_font_weight character varying(11) DEFAULT 'medium'::character varying NOT NULL,
    heading_5_font_weight character varying(11) DEFAULT 'regular'::character varying NOT NULL,
    heading_6_font_weight character varying(11) DEFAULT 'regular'::character varying NOT NULL,
    heading_1_text_decoration character varying(4) DEFAULT '0000'::character varying NOT NULL,
    heading_2_text_decoration character varying(4) DEFAULT '0000'::character varying NOT NULL,
    heading_3_text_decoration character varying(4) DEFAULT '0000'::character varying NOT NULL,
    heading_4_text_decoration character varying(4) DEFAULT '0000'::character varying NOT NULL,
    heading_5_text_decoration character varying(4) DEFAULT '0000'::character varying NOT NULL,
    heading_6_text_decoration character varying(4) DEFAULT '0000'::character varying NOT NULL
);


--
-- Name: builder_typographythemeconfigblock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.builder_typographythemeconfigblock ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.builder_typographythemeconfigblock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_action; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_action (
    id integer NOT NULL,
    session text,
    created_on timestamp with time zone NOT NULL,
    type text NOT NULL,
    params jsonb NOT NULL,
    scope text NOT NULL,
    undone_at timestamp with time zone,
    error text,
    user_id integer,
    updated_on timestamp with time zone NOT NULL,
    action_group uuid,
    workspace_id integer
);


--
-- Name: core_action_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_action ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_action_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_appauthprovider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_appauthprovider (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    domain character varying(255),
    enabled boolean NOT NULL,
    content_type_id integer NOT NULL,
    user_source_id integer NOT NULL
);


--
-- Name: core_appauthprovider_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_appauthprovider ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_appauthprovider_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_application; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_application (
    id integer NOT NULL,
    name character varying(160) NOT NULL,
    "order" integer NOT NULL,
    content_type_id integer NOT NULL,
    workspace_id integer,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    installed_from_template_id integer,
    CONSTRAINT core_application_order_check CHECK (("order" >= 0))
);


--
-- Name: core_application_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_application ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_application_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_authprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_authprovidermodel (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    domain character varying(255),
    enabled boolean NOT NULL,
    content_type_id integer NOT NULL
);


--
-- Name: core_authprovidermodel_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_authprovidermodel ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_authprovidermodel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_authprovidermodel_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_authprovidermodel_users (
    id integer NOT NULL,
    authprovidermodel_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: core_authprovidermodel_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_authprovidermodel_users ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_authprovidermodel_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_blacklistedtoken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_blacklistedtoken (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    hashed_token character varying(64) NOT NULL,
    expires_at timestamp with time zone NOT NULL
);


--
-- Name: core_blacklistedtoken_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_blacklistedtoken ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_blacklistedtoken_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_createsnapshotjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_createsnapshotjob (
    job_ptr_id integer NOT NULL,
    snapshot_id integer,
    user_ip_address inet
);


--
-- Name: core_duplicateapplicationjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_duplicateapplicationjob (
    job_ptr_id integer NOT NULL,
    user_session_id character varying(36),
    user_websocket_id character varying(36),
    duplicated_application_id integer,
    original_application_id integer,
    user_action_group_id character varying(36),
    user_ip_address inet
);


--
-- Name: core_exportapplicationsjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_exportapplicationsjob (
    job_ptr_id integer NOT NULL,
    user_ip_address inet,
    user_websocket_id character varying(36),
    user_session_id character varying(36),
    user_action_group_id character varying(36),
    only_structure boolean NOT NULL,
    workspace_id integer,
    application_ids jsonb NOT NULL,
    resource_id integer
);


--
-- Name: core_workspace; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_workspace (
    id integer NOT NULL,
    name character varying(165) NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    storage_usage integer,
    storage_usage_updated_at timestamp with time zone,
    seats_taken integer,
    seats_taken_updated_at timestamp with time zone,
    now timestamp with time zone,
    generative_ai_models_settings jsonb
);


--
-- Name: core_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_workspace ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_workspaceinvitation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_workspaceinvitation (
    id integer NOT NULL,
    email character varying(254) NOT NULL,
    permissions character varying(32) NOT NULL,
    message text NOT NULL,
    workspace_id integer NOT NULL,
    invited_by_id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL
);


--
-- Name: core_groupinvitation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_workspaceinvitation ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_groupinvitation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_workspaceuser; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_workspaceuser (
    id integer NOT NULL,
    "order" integer NOT NULL,
    workspace_id integer NOT NULL,
    user_id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    permissions character varying(32) NOT NULL,
    CONSTRAINT core_groupuser_order_check CHECK (("order" >= 0))
);


--
-- Name: core_groupuser_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_workspaceuser ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_groupuser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_importapplicationsjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_importapplicationsjob (
    job_ptr_id integer NOT NULL,
    user_ip_address inet,
    user_websocket_id character varying(36),
    user_session_id character varying(36),
    user_action_group_id character varying(36),
    application_ids jsonb NOT NULL,
    only_structure boolean NOT NULL,
    workspace_id integer,
    resource_id integer
);


--
-- Name: core_importexportresource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_importexportresource (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    uuid uuid NOT NULL,
    original_name character varying(255) NOT NULL,
    size bigint NOT NULL,
    is_valid boolean NOT NULL,
    marked_for_deletion boolean NOT NULL,
    created_by_id integer,
    CONSTRAINT core_importexportresource_size_check CHECK ((size >= 0))
);


--
-- Name: core_importexportresource_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_importexportresource ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_importexportresource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_importexporttrustedsource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_importexporttrustedsource (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    private_key text NOT NULL,
    public_key text NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: core_importexporttrustedsource_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_importexporttrustedsource ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_importexporttrustedsource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_installtemplatejob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_installtemplatejob (
    job_ptr_id integer NOT NULL,
    user_websocket_id character varying(36),
    user_session_id character varying(36),
    user_action_group_id character varying(36),
    installed_applications jsonb NOT NULL,
    workspace_id integer NOT NULL,
    template_id integer NOT NULL,
    user_ip_address inet
);


--
-- Name: core_integration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_integration (
    id integer NOT NULL,
    trashed boolean NOT NULL,
    name character varying(255) NOT NULL,
    "order" numeric(40,20) NOT NULL,
    application_id integer NOT NULL,
    content_type_id integer NOT NULL
);


--
-- Name: core_integration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_integration ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_integration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_job; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_job (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    progress_percentage integer NOT NULL,
    state character varying(128) NOT NULL,
    error text NOT NULL,
    human_readable_error text NOT NULL,
    content_type_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: core_job_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_job ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_mcpendpoint; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_mcpendpoint (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    key character varying(32) NOT NULL,
    created timestamp with time zone NOT NULL,
    user_id integer NOT NULL,
    workspace_id integer NOT NULL
);


--
-- Name: core_mcpendpoint_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_mcpendpoint ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_mcpendpoint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_notification (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    type character varying(64) NOT NULL,
    broadcast boolean NOT NULL,
    data jsonb NOT NULL,
    sender_id integer,
    workspace_id integer
);


--
-- Name: core_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_notification ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_notificationrecipient; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_notificationrecipient (
    id integer NOT NULL,
    read boolean NOT NULL,
    cleared boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    broadcast boolean NOT NULL,
    workspace_id bigint,
    notification_id integer NOT NULL,
    recipient_id integer,
    queued boolean NOT NULL,
    email_scheduled boolean NOT NULL
);


--
-- Name: core_notificationrecipient_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_notificationrecipient ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_notificationrecipient_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_operation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_operation (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: core_operation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_operation ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_operation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_passwordauthprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_passwordauthprovidermodel (
    authprovidermodel_ptr_id integer NOT NULL
);


--
-- Name: core_restoresnapshotjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_restoresnapshotjob (
    job_ptr_id integer NOT NULL,
    snapshot_id integer,
    user_ip_address inet
);


--
-- Name: core_schemaoperation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_schemaoperation (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    operation character varying(64) NOT NULL,
    content_type_id integer NOT NULL
);


--
-- Name: core_schemaoperation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_schemaoperation ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_schemaoperation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_service; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_service (
    id integer NOT NULL,
    trashed boolean NOT NULL,
    content_type_id integer NOT NULL,
    integration_id integer,
    sample_data jsonb
);


--
-- Name: core_service_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_service ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_settings (
    id integer NOT NULL,
    allow_new_signups boolean NOT NULL,
    instance_id character varying(50) NOT NULL,
    allow_reset_password boolean NOT NULL,
    account_deletion_grace_delay smallint NOT NULL,
    show_admin_signup_page boolean NOT NULL,
    track_workspace_usage boolean NOT NULL,
    allow_global_workspace_creation boolean NOT NULL,
    allow_signups_via_workspace_invitations boolean NOT NULL,
    co_branding_logo_id integer,
    show_baserow_help_request boolean NOT NULL,
    email_verification text,
    verify_import_signature boolean DEFAULT true NOT NULL,
    CONSTRAINT core_settings_account_deletion_grace_delay_check CHECK ((account_deletion_grace_delay >= 0))
);


--
-- Name: core_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_settings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_snapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_snapshot (
    id integer NOT NULL,
    name character varying(160) NOT NULL,
    mark_for_deletion boolean NOT NULL,
    created_at timestamp with time zone NOT NULL,
    created_by_id integer,
    snapshot_from_application_id integer NOT NULL,
    snapshot_to_application_id integer
);


--
-- Name: core_snapshot_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_snapshot ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_snapshot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_template (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    slug character varying(50) NOT NULL,
    icon character varying(32) NOT NULL,
    workspace_id integer,
    export_hash character varying(64) NOT NULL,
    keywords text NOT NULL,
    open_application integer
);


--
-- Name: core_template_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_template_categories (
    id integer NOT NULL,
    template_id integer NOT NULL,
    templatecategory_id integer NOT NULL
);


--
-- Name: core_template_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_template_categories ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_template_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_template_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_template ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_templatecategory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_templatecategory (
    id integer NOT NULL,
    name character varying(32) NOT NULL
);


--
-- Name: core_templatecategory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_templatecategory ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_templatecategory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_totpauthprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_totpauthprovidermodel (
    twofactorauthprovidermodel_ptr_id integer NOT NULL,
    enabled boolean NOT NULL,
    secret character varying(32) NOT NULL,
    provisioning_url character varying(255) NOT NULL,
    provisioning_qr_code text NOT NULL
);


--
-- Name: core_totpusedcode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_totpusedcode (
    id integer NOT NULL,
    used_at timestamp with time zone NOT NULL,
    code character varying(64) NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: core_totpusedcode_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_totpusedcode ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_totpusedcode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_trashentry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_trashentry (
    id integer NOT NULL,
    trash_item_type text NOT NULL,
    parent_trash_item_id integer,
    trash_item_id integer NOT NULL,
    should_be_permanently_deleted boolean NOT NULL,
    trashed_at timestamp with time zone NOT NULL,
    name text NOT NULL,
    parent_name text,
    extra_description text,
    application_id integer,
    workspace_id integer NOT NULL,
    user_who_trashed_id integer,
    names text[],
    related_items jsonb,
    trash_item_owner_id integer,
    additional_restoration_data jsonb,
    trash_operation_type character varying(125),
    CONSTRAINT core_trashentry_parent_trash_item_id_check CHECK ((parent_trash_item_id >= 0)),
    CONSTRAINT core_trashentry_trash_item_id_check CHECK ((trash_item_id >= 0))
);


--
-- Name: core_trashentry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_trashentry ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_trashentry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_twofactorauthprovidermodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_twofactorauthprovidermodel (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    content_type_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: core_twofactorauthprovidermodel_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_twofactorauthprovidermodel ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_twofactorauthprovidermodel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_twofactorauthrecoverycode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_twofactorauthrecoverycode (
    id integer NOT NULL,
    code character varying(64) NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: core_twofactorauthrecoverycode_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_twofactorauthrecoverycode ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_twofactorauthrecoverycode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_userfile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_userfile (
    id integer NOT NULL,
    original_name character varying(255) NOT NULL,
    original_extension character varying(64) NOT NULL,
    "unique" character varying(32) NOT NULL,
    size bigint NOT NULL,
    mime_type character varying(127) NOT NULL,
    is_image boolean NOT NULL,
    image_width integer,
    image_height integer,
    uploaded_at timestamp with time zone NOT NULL,
    sha256_hash character varying(64) NOT NULL,
    uploaded_by_id integer,
    deleted_at timestamp with time zone,
    CONSTRAINT core_userfile_image_height_check CHECK ((image_height >= 0)),
    CONSTRAINT core_userfile_image_width_check CHECK ((image_width >= 0)),
    CONSTRAINT core_userfile_size_check CHECK ((size >= 0))
);


--
-- Name: core_userfile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_userfile ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_userfile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_userlogentry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_userlogentry (
    id integer NOT NULL,
    action character varying(20) NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    actor_id integer NOT NULL
);


--
-- Name: core_userlogentry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_userlogentry ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_userlogentry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_userprofile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_userprofile (
    id integer NOT NULL,
    language text NOT NULL,
    user_id integer NOT NULL,
    to_be_deleted boolean NOT NULL,
    concurrency_limit smallint,
    email_notification_frequency text NOT NULL,
    last_notifications_email_sent_at timestamp with time zone,
    timezone character varying(255),
    last_password_change timestamp with time zone,
    email_verified boolean,
    completed_onboarding boolean,
    completed_guided_tours text[]
);


--
-- Name: core_userprofile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_userprofile ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_userprofile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: core_usersource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_usersource (
    id integer NOT NULL,
    trashed boolean NOT NULL,
    name character varying(255) NOT NULL,
    "order" numeric(40,20) NOT NULL,
    application_id integer NOT NULL,
    content_type_id integer NOT NULL,
    integration_id integer,
    uid text NOT NULL
);


--
-- Name: core_usersource_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.core_usersource ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.core_usersource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: dashboard_dashboard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_dashboard (
    application_ptr_id integer NOT NULL,
    description text DEFAULT ''::text NOT NULL
);


--
-- Name: dashboard_dashboarddatasource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_dashboarddatasource (
    id integer NOT NULL,
    trashed boolean NOT NULL,
    name character varying(255) NOT NULL,
    "order" numeric(40,20) NOT NULL,
    dashboard_id integer NOT NULL,
    service_id integer
);


--
-- Name: dashboard_dashboarddatasource_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.dashboard_dashboarddatasource ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.dashboard_dashboarddatasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: dashboard_summarywidget; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_summarywidget (
    widget_ptr_id integer NOT NULL,
    data_source_id integer NOT NULL
);


--
-- Name: dashboard_widget; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_widget (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    title character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    "order" numeric(40,20) NOT NULL,
    content_type_id integer NOT NULL,
    dashboard_id integer NOT NULL
);


--
-- Name: dashboard_widget_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.dashboard_widget ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.dashboard_widget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_airtableimportjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_airtableimportjob (
    job_ptr_id integer NOT NULL,
    airtable_share_id character varying(200) NOT NULL,
    database_id integer,
    workspace_id integer NOT NULL,
    user_ip_address inet,
    skip_files boolean DEFAULT false NOT NULL,
    session character varying,
    session_signature character varying
);


--
-- Name: database_autonumberfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_autonumberfield (
    field_ptr_id integer NOT NULL
);


--
-- Name: database_booleanfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_booleanfield (
    field_ptr_id integer NOT NULL,
    boolean_default boolean DEFAULT false NOT NULL
);


--
-- Name: database_calendarview; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_calendarview (
    view_ptr_id integer NOT NULL,
    date_field_id integer,
    ical_public boolean,
    ical_slug character varying(50)
);


--
-- Name: database_calendarviewfieldoptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_calendarviewfieldoptions (
    id integer NOT NULL,
    hidden boolean NOT NULL,
    "order" smallint NOT NULL,
    calendar_view_id integer NOT NULL,
    field_id integer NOT NULL
);


--
-- Name: database_calendarviewfieldoptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_calendarviewfieldoptions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_calendarviewfieldoptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_countfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_countfield (
    formulafield_ptr_id integer NOT NULL,
    through_field_id integer
);


--
-- Name: database_createdbyfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_createdbyfield (
    field_ptr_id integer NOT NULL
);


--
-- Name: database_createdonfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_createdonfield (
    field_ptr_id integer NOT NULL,
    date_format character varying(32) NOT NULL,
    date_include_time boolean NOT NULL,
    date_time_format character varying(32) NOT NULL,
    date_force_timezone character varying(255),
    date_show_tzinfo boolean NOT NULL
);


--
-- Name: database_database; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_database (
    application_ptr_id integer NOT NULL
);


--
-- Name: database_datasync; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_datasync (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    last_sync timestamp with time zone,
    last_error text,
    content_type_id integer NOT NULL,
    table_id integer NOT NULL,
    auto_add_new_properties boolean DEFAULT false NOT NULL,
    two_way_sync boolean DEFAULT false NOT NULL,
    two_way_sync_consecutive_failures smallint DEFAULT 0 NOT NULL,
    delete_unmatched_rows boolean DEFAULT true NOT NULL,
    CONSTRAINT database_datasync_two_way_sync_consecutive_failures_check CHECK ((two_way_sync_consecutive_failures >= 0))
);


--
-- Name: database_datasync_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_datasync ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_datasync_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_datasyncsyncedproperty; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_datasyncsyncedproperty (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    unique_primary boolean NOT NULL,
    data_sync_id integer NOT NULL,
    field_id integer NOT NULL,
    metadata jsonb
);


--
-- Name: database_datasyncsyncedproperty_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_datasyncsyncedproperty ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_datasyncsyncedproperty_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_datefield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_datefield (
    field_ptr_id integer NOT NULL,
    date_format character varying(32) NOT NULL,
    date_include_time boolean NOT NULL,
    date_time_format character varying(32) NOT NULL,
    date_force_timezone character varying(255),
    date_show_tzinfo boolean NOT NULL,
    date_default_now boolean DEFAULT false NOT NULL
);


--
-- Name: database_duplicatefieldjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_duplicatefieldjob (
    job_ptr_id integer NOT NULL,
    user_websocket_id character varying(36),
    user_session_id character varying(36),
    user_action_group_id character varying(36),
    duplicate_data boolean NOT NULL,
    duplicated_field_id integer,
    original_field_id integer,
    user_ip_address inet
);


--
-- Name: database_duplicatetablejob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_duplicatetablejob (
    job_ptr_id integer NOT NULL,
    user_session_id character varying(36),
    user_websocket_id character varying(36),
    duplicated_table_id integer,
    original_table_id integer,
    user_action_group_id character varying(36),
    user_ip_address inet
);


--
-- Name: database_durationfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_durationfield (
    field_ptr_id integer NOT NULL,
    duration_format character varying(32) NOT NULL
);


--
-- Name: database_emailfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_emailfield (
    field_ptr_id integer NOT NULL
);


--
-- Name: database_exportjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_exportjob (
    id integer NOT NULL,
    exporter_type text NOT NULL,
    state text NOT NULL,
    exported_file_name text,
    error text,
    created_at timestamp with time zone NOT NULL,
    progress_percentage double precision NOT NULL,
    export_options jsonb NOT NULL,
    table_id integer,
    user_id integer,
    view_id integer
);


--
-- Name: database_exportjob_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_exportjob ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_exportjob_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_field; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_field (
    id integer NOT NULL,
    "order" integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    table_id integer NOT NULL,
    "primary" boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    tsvector_column_created boolean NOT NULL,
    description text,
    immutable_properties boolean NOT NULL,
    immutable_type boolean NOT NULL,
    read_only boolean NOT NULL,
    db_index boolean DEFAULT false NOT NULL,
    search_data_initialized_at timestamp with time zone,
    CONSTRAINT database_field_order_check CHECK (("order" >= 0))
);


--
-- Name: database_field_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_field ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_field_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_fieldconstraint; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_fieldconstraint (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    type_name character varying(255) NOT NULL,
    field_id integer NOT NULL
);


--
-- Name: database_fieldconstraint_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_fieldconstraint ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_fieldconstraint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_fielddependency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_fielddependency (
    id integer NOT NULL,
    broken_reference_field_name text,
    dependant_id integer NOT NULL,
    dependency_id integer,
    via_id integer
);


--
-- Name: database_fielddependency_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_fielddependency ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_fielddependency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_fieldrule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_fieldrule (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    is_active boolean NOT NULL,
    is_valid boolean NOT NULL,
    error_text text,
    content_type_id integer NOT NULL,
    table_id integer NOT NULL
);


--
-- Name: database_fieldrule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_fieldrule ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_fieldrule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_filefield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_filefield (
    field_ptr_id integer NOT NULL
);


--
-- Name: database_fileimportjob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_fileimportjob (
    job_ptr_id integer NOT NULL,
    data_file character varying(100),
    table_id integer,
    report jsonb NOT NULL,
    database_id integer,
    first_row_header boolean NOT NULL,
    name character varying(255) NOT NULL,
    user_session_id character varying(36),
    user_websocket_id character varying(36),
    user_action_group_id character varying(36),
    user_ip_address inet,
    importer_type text,
    original_file_name text
);


--
-- Name: database_formulafield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_formulafield (
    field_ptr_id integer NOT NULL,
    formula text NOT NULL,
    error text,
    formula_type text NOT NULL,
    number_decimal_places integer,
    date_format character varying(32),
    date_include_time boolean,
    date_time_format character varying(32),
    old_formula_with_field_by_id text,
    version integer NOT NULL,
    internal_formula text NOT NULL,
    requires_refresh_after_insert boolean NOT NULL,
    array_formula_type text,
    nullable boolean NOT NULL,
    date_force_timezone character varying(255),
    date_show_tzinfo boolean,
    needs_periodic_update boolean NOT NULL,
    duration_format character varying(32),
    expand_formula_when_referenced boolean,
    number_prefix character varying(10) DEFAULT ''::character varying NOT NULL,
    number_separator character varying(16) DEFAULT ''::character varying NOT NULL,
    number_suffix character varying(10) DEFAULT ''::character varying NOT NULL
);


--
-- Name: database_formview; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_formview (
    view_ptr_id integer NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    submit_action character varying(32) NOT NULL,
    submit_action_message text NOT NULL,
    submit_action_redirect_url character varying(2000) NOT NULL,
    cover_image_id integer,
    logo_image_id integer,
    submit_text text NOT NULL,
    mode text NOT NULL
);


--
-- Name: database_formview_users_to_notify_on_submit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_formview_users_to_notify_on_submit (
    id integer NOT NULL,
    formview_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: database_formview_users_to_notify_on_submit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_formview_users_to_notify_on_submit ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_formview_users_to_notify_on_submit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_formvieweditrowfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_formvieweditrowfield (
    field_ptr_id integer NOT NULL,
    form_view_id integer
);


--
-- Name: database_formviewfieldoptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_formviewfieldoptions (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    enabled boolean NOT NULL,
    required boolean NOT NULL,
    "order" smallint NOT NULL,
    field_id integer NOT NULL,
    form_view_id integer NOT NULL,
    condition_type character varying(3) NOT NULL,
    show_when_matching_conditions boolean NOT NULL,
    field_component character varying(32) NOT NULL,
    include_all_select_options boolean DEFAULT true NOT NULL
);


--
-- Name: database_formviewfieldoptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_formviewfieldoptions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_formviewfieldoptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_formviewfieldoptionsallowedselectoptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_formviewfieldoptionsallowedselectoptions (
    id integer NOT NULL,
    form_view_field_options_id integer NOT NULL,
    select_option_id integer NOT NULL
);


--
-- Name: database_formviewfieldoptionsallowedselectoptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_formviewfieldoptionsallowedselectoptions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_formviewfieldoptionsallowedselectoptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_formviewfieldoptionscondition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_formviewfieldoptionscondition (
    id integer NOT NULL,
    type character varying(48) NOT NULL,
    value text NOT NULL,
    field_id integer NOT NULL,
    field_option_id integer NOT NULL,
    group_id integer
);


--
-- Name: database_formviewfieldoptionscondition_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_formviewfieldoptionscondition ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_formviewfieldoptionscondition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_formviewfieldoptionsconditiongroup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_formviewfieldoptionsconditiongroup (
    id integer NOT NULL,
    filter_type character varying(3) NOT NULL,
    field_option_id integer NOT NULL,
    parent_group_id integer
);


--
-- Name: database_formviewfieldoptionsconditiongroup_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_formviewfieldoptionsconditiongroup ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_formviewfieldoptionsconditiongroup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_galleryview; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_galleryview (
    view_ptr_id integer NOT NULL,
    card_cover_image_field_id integer
);


--
-- Name: database_galleryviewfieldoptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_galleryviewfieldoptions (
    id integer NOT NULL,
    hidden boolean NOT NULL,
    "order" smallint NOT NULL,
    field_id integer NOT NULL,
    gallery_view_id integer NOT NULL
);


--
-- Name: database_galleryviewfieldoptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_galleryviewfieldoptions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_galleryviewfieldoptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_gridview; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_gridview (
    view_ptr_id integer NOT NULL,
    row_identifier_type character varying(10) NOT NULL,
    row_height_size character varying(10) DEFAULT 'small'::character varying NOT NULL,
    frozen_column_count smallint DEFAULT 1 NOT NULL,
    CONSTRAINT database_gridview_frozen_column_count_check CHECK ((frozen_column_count >= 0))
);


--
-- Name: database_gridviewfieldoptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_gridviewfieldoptions (
    id integer NOT NULL,
    width integer NOT NULL,
    field_id integer NOT NULL,
    grid_view_id integer NOT NULL,
    hidden boolean NOT NULL,
    "order" smallint NOT NULL,
    aggregation_raw_type character varying(48) NOT NULL,
    aggregation_type character varying(48) NOT NULL,
    CONSTRAINT database_gridviewfieldoptions_width_check CHECK ((width >= 0))
);


--
-- Name: database_gridviewfieldoptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_gridviewfieldoptions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_gridviewfieldoptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_icalcalendardatasync; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_icalcalendardatasync (
    datasync_ptr_id integer NOT NULL,
    ical_url character varying(2000) NOT NULL
);


--
-- Name: database_kanbanview; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_kanbanview (
    view_ptr_id integer NOT NULL,
    single_select_field_id integer,
    card_cover_image_field_id integer
);


--
-- Name: database_kanbanviewfieldoptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_kanbanviewfieldoptions (
    id integer NOT NULL,
    hidden boolean NOT NULL,
    "order" smallint NOT NULL,
    field_id integer NOT NULL,
    kanban_view_id integer NOT NULL
);


--
-- Name: database_kanbanviewfieldoptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_kanbanviewfieldoptions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_kanbanviewfieldoptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_lastmodifiedbyfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_lastmodifiedbyfield (
    field_ptr_id integer NOT NULL
);


--
-- Name: database_lastmodifiedfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_lastmodifiedfield (
    field_ptr_id integer NOT NULL,
    date_format character varying(32) NOT NULL,
    date_include_time boolean NOT NULL,
    date_time_format character varying(32) NOT NULL,
    date_force_timezone character varying(255),
    date_show_tzinfo boolean NOT NULL
);


--
-- Name: database_linkrowfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_linkrowfield (
    field_ptr_id integer NOT NULL,
    link_row_relation_id integer,
    link_row_related_field_id integer,
    link_row_table_id integer NOT NULL,
    link_row_limit_selection_view_id integer,
    link_row_multiple_relationships boolean DEFAULT true NOT NULL
);


--
-- Name: database_linkrowfield_link_row_relation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.database_linkrowfield_link_row_relation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: database_linkrowfield_link_row_relation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.database_linkrowfield_link_row_relation_id_seq OWNED BY public.database_linkrowfield.link_row_relation_id;


--
-- Name: database_longtextfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_longtextfield (
    field_ptr_id integer NOT NULL,
    long_text_enable_rich_text boolean
);


--
-- Name: database_lookupfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_lookupfield (
    formulafield_ptr_id integer NOT NULL,
    through_field_name character varying(255) NOT NULL,
    target_field_name character varying(255) NOT NULL,
    target_field_id integer,
    through_field_id integer
);


--
-- Name: database_multiplecollaboratorsfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_multiplecollaboratorsfield (
    field_ptr_id integer NOT NULL,
    notify_user_when_added boolean NOT NULL,
    multiple_collaborators_default bigint[]
);


--
-- Name: database_multipleselect_46; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_multipleselect_46 (
    id integer NOT NULL,
    table7model_id integer NOT NULL,
    multipleselectfield46selectoption_id integer NOT NULL
);


--
-- Name: database_multipleselect_46_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_multipleselect_46 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_multipleselect_46_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_multipleselectfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_multipleselectfield (
    field_ptr_id integer NOT NULL,
    multiple_select_default bigint[]
);


--
-- Name: database_numberfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_numberfield (
    field_ptr_id integer NOT NULL,
    number_decimal_places integer NOT NULL,
    number_negative boolean NOT NULL,
    number_prefix character varying(10) DEFAULT ''::character varying NOT NULL,
    number_separator character varying(16) DEFAULT ''::character varying NOT NULL,
    number_suffix character varying(100) DEFAULT ''::character varying NOT NULL,
    number_default numeric(50,20)
);


--
-- Name: database_passwordfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_passwordfield (
    field_ptr_id integer NOT NULL,
    allow_endpoint_authentication boolean DEFAULT false NOT NULL
);


--
-- Name: database_pendingsearchvalueupdate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_pendingsearchvalueupdate (
    id bigint NOT NULL,
    row_id integer,
    field_id integer NOT NULL,
    table_id integer,
    deletion_workspace_id integer,
    updated_on timestamp with time zone DEFAULT statement_timestamp() NOT NULL
)
WITH (autovacuum_analyze_threshold='2000', autovacuum_analyze_scale_factor='0.002', autovacuum_vacuum_threshold='5000', autovacuum_vacuum_scale_factor='0.01', autovacuum_vacuum_insert_threshold='5000', autovacuum_vacuum_insert_scale_factor='0.01');
ALTER TABLE ONLY public.database_pendingsearchvalueupdate ALTER COLUMN field_id SET STATISTICS 2000;


--
-- Name: database_pendingsearchvalueupdate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_pendingsearchvalueupdate ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_pendingsearchvalueupdate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_phonenumberfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_phonenumberfield (
    field_ptr_id integer NOT NULL
);


--
-- Name: database_postgresqldatasync; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_postgresqldatasync (
    datasync_ptr_id integer NOT NULL,
    postgresql_host character varying(255) NOT NULL,
    postgresql_username character varying(255) NOT NULL,
    postgresql_password character varying(255) NOT NULL,
    postgresql_port smallint NOT NULL,
    postgresql_database character varying(255) NOT NULL,
    postgresql_schema character varying(255) NOT NULL,
    postgresql_table character varying(255) NOT NULL,
    postgresql_sslmode character varying(12) NOT NULL,
    CONSTRAINT database_postgresqldatasync_postgresql_port_check CHECK ((postgresql_port >= 0))
);


--
-- Name: database_ratingfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_ratingfield (
    field_ptr_id integer NOT NULL,
    max_value smallint NOT NULL,
    color character varying(50) NOT NULL,
    style character varying(50) NOT NULL,
    CONSTRAINT database_ratingfield_max_value_check CHECK ((max_value >= 0))
);


--
-- Name: database_relation_1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_relation_1 (
    id integer NOT NULL,
    table1model_id integer NOT NULL,
    table4model_id integer NOT NULL
);


--
-- Name: database_relation_1_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_relation_1 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_relation_1_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_relation_2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_relation_2 (
    id integer NOT NULL,
    table1model_id integer NOT NULL,
    table2model_id integer NOT NULL
);


--
-- Name: database_relation_2_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_relation_2 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_relation_2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_relation_3; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_relation_3 (
    id integer NOT NULL,
    table1model_id integer NOT NULL,
    table6model_id integer NOT NULL
);


--
-- Name: database_relation_3_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_relation_3 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_relation_3_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_relation_4; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_relation_4 (
    id integer NOT NULL,
    table1model_id integer NOT NULL,
    table5model_id integer NOT NULL
);


--
-- Name: database_relation_4_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_relation_4 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_relation_4_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_relation_5; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_relation_5 (
    id integer NOT NULL,
    table2model_id integer NOT NULL,
    table3model_id integer NOT NULL
);


--
-- Name: database_relation_5_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_relation_5 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_relation_5_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_relation_6; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_relation_6 (
    id integer NOT NULL,
    table6model_id integer NOT NULL,
    table7model_id integer NOT NULL
);


--
-- Name: database_relation_6_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_relation_6 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_relation_6_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_relation_7; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_relation_7 (
    id integer NOT NULL,
    table8model_id integer NOT NULL,
    table9model_id integer NOT NULL
);


--
-- Name: database_relation_7_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_relation_7 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_relation_7_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_richtextfieldmention; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_richtextfieldmention (
    id integer NOT NULL,
    row_id integer NOT NULL,
    marked_for_deletion_at timestamp with time zone,
    field_id integer NOT NULL,
    table_id integer NOT NULL,
    user_id integer NOT NULL,
    CONSTRAINT database_richtextfieldmention_row_id_check CHECK ((row_id >= 0))
);


--
-- Name: database_richtextfieldmention_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_richtextfieldmention ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_richtextfieldmention_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_rollupfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_rollupfield (
    formulafield_ptr_id integer NOT NULL,
    rollup_function character varying(64) NOT NULL,
    target_field_id integer,
    through_field_id integer
);


--
-- Name: database_rowcomment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_rowcomment (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    row_id integer NOT NULL,
    comment text,
    table_id integer NOT NULL,
    user_id integer,
    trashed boolean NOT NULL,
    message jsonb NOT NULL,
    CONSTRAINT database_rowcomment_row_id_check CHECK ((row_id >= 0))
);


--
-- Name: database_rowcomment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_rowcomment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_rowcomment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_rowcomment_mentions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_rowcomment_mentions (
    id integer NOT NULL,
    rowcomment_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: database_rowcomment_mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_rowcomment_mentions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_rowcomment_mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_rowhistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_rowhistory (
    id integer NOT NULL,
    user_id integer,
    user_name character varying(150) NOT NULL,
    row_id integer NOT NULL,
    field_names character varying(255)[] NOT NULL,
    fields_metadata jsonb NOT NULL,
    action_uuid character varying(36) NOT NULL,
    action_command_type character varying(4) NOT NULL,
    action_type text NOT NULL,
    action_timestamp timestamp with time zone NOT NULL,
    before_values jsonb NOT NULL,
    after_values jsonb NOT NULL,
    table_id integer NOT NULL,
    CONSTRAINT database_rowhistory_row_id_check CHECK ((row_id >= 0)),
    CONSTRAINT database_rowhistory_user_id_check CHECK ((user_id >= 0))
);


--
-- Name: database_rowhistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_rowhistory ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_rowhistory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_selectoption; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_selectoption (
    id integer NOT NULL,
    value character varying(255) NOT NULL,
    color character varying(255) NOT NULL,
    "order" integer NOT NULL,
    field_id integer NOT NULL,
    CONSTRAINT database_selectoption_order_check CHECK (("order" >= 0))
);


--
-- Name: database_selectoption_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_selectoption ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_selectoption_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_singleselectfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_singleselectfield (
    field_ptr_id integer NOT NULL,
    single_select_default bigint,
    CONSTRAINT database_singleselectfield_single_select_default_check CHECK ((single_select_default >= 0))
);


--
-- Name: database_syncdatasynctablejob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_syncdatasynctablejob (
    job_ptr_id integer NOT NULL,
    data_sync_id integer
);


--
-- Name: database_table; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_table (
    id integer NOT NULL,
    "order" integer NOT NULL,
    name character varying(255) NOT NULL,
    database_id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    row_count integer,
    row_count_updated_at timestamp with time zone,
    version text NOT NULL,
    needs_background_update_column_added boolean NOT NULL,
    last_modified_by_column_added boolean,
    created_by_column_added boolean,
    field_rules_validity_column_added boolean DEFAULT false,
    missing_m2m_indexes_added boolean DEFAULT false NOT NULL,
    CONSTRAINT database_table_order_check CHECK (("order" >= 0)),
    CONSTRAINT database_table_row_count_check CHECK ((row_count >= 0))
);


--
-- Name: database_table_1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_table_1 (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    field_1 timestamp with time zone,
    field_2 integer,
    field_5 text,
    field_6 text,
    field_9 boolean NOT NULL,
    field_50 jsonb,
    field_51 jsonb,
    "order" numeric(40,20) NOT NULL,
    created_by_id integer,
    last_modified_by_id integer
);


--
-- Name: database_table_1_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_table_1 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_table_1_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_table_2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_table_2 (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    field_10 text,
    field_11 integer,
    field_13 integer,
    field_15 text,
    field_16 numeric(50,0),
    field_53 numeric(50,0),
    field_54 jsonb,
    "order" numeric(40,20) NOT NULL,
    created_by_id integer,
    last_modified_by_id integer
);


--
-- Name: database_table_2_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_table_2 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_table_2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_table_3; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_table_3 (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    field_17 text,
    field_18 text,
    field_19 boolean NOT NULL,
    field_21 character varying(100),
    field_22 text,
    field_23 text,
    field_52 jsonb,
    "order" numeric(40,20) NOT NULL,
    created_by_id integer,
    last_modified_by_id integer
);


--
-- Name: database_table_3_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_table_3 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_table_3_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_table_4; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_table_4 (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    field_24 text,
    field_25 text,
    field_27 text,
    field_28 smallint NOT NULL,
    "order" numeric(40,20) NOT NULL,
    created_by_id integer,
    last_modified_by_id integer,
    CONSTRAINT database_table_4_field_28_check CHECK ((field_28 >= 0))
);


--
-- Name: database_table_4_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_table_4 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_table_4_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_table_5; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_table_5 (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    field_29 text,
    field_30 text,
    field_31 boolean NOT NULL,
    field_33 jsonb NOT NULL,
    field_34 text,
    field_56 jsonb,
    field_57 jsonb,
    "order" numeric(40,20) NOT NULL,
    created_by_id integer,
    last_modified_by_id integer
);


--
-- Name: database_table_5_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_table_5 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_table_5_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_table_6; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_table_6 (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    field_35 text,
    field_36 text,
    field_39 text,
    field_40 numeric(50,0),
    field_41 numeric(50,0),
    field_42 text,
    field_55 text,
    field_58 jsonb,
    "order" numeric(40,20) NOT NULL,
    created_by_id integer,
    last_modified_by_id integer
);


--
-- Name: database_table_6_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_table_6 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_table_6_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_table_7; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_table_7 (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    field_43 text,
    field_44 text,
    field_45 boolean NOT NULL,
    field_48 boolean NOT NULL,
    field_49 text,
    "order" numeric(40,20) NOT NULL,
    created_by_id integer,
    last_modified_by_id integer
);


--
-- Name: database_table_7_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_table_7 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_table_7_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_table_8; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_table_8 (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    field_59 text,
    field_60 integer,
    field_64 text,
    "order" numeric(40,20) NOT NULL,
    created_by_id integer,
    last_modified_by_id integer
);


--
-- Name: database_table_8_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_table_8 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_table_8_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_table_9; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_table_9 (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    trashed boolean NOT NULL,
    field_62 text,
    field_63 text,
    "order" numeric(40,20) NOT NULL,
    created_by_id integer,
    last_modified_by_id integer
);


--
-- Name: database_table_9_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_table_9 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_table_9_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_table_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_table ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_tableusage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_tableusage (
    id integer NOT NULL,
    row_count integer,
    row_count_updated_at timestamp with time zone,
    storage_usage integer,
    storage_usage_updated_at timestamp with time zone,
    table_id integer NOT NULL,
    CONSTRAINT database_tableusage_row_count_check CHECK ((row_count >= 0)),
    CONSTRAINT database_tableusage_storage_usage_check CHECK ((storage_usage >= 0))
);


--
-- Name: database_tableusage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_tableusage ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_tableusage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_tableusageupdate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_tableusageupdate (
    id bigint NOT NULL,
    row_count integer,
    "timestamp" timestamp with time zone NOT NULL,
    table_id integer NOT NULL
);


--
-- Name: database_tableusageupdate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_tableusageupdate ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_tableusageupdate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_tablewebhook; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_tablewebhook (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    active boolean NOT NULL,
    use_user_field_names boolean NOT NULL,
    url text NOT NULL,
    request_method character varying(10) NOT NULL,
    name character varying(255) NOT NULL,
    include_all_events boolean NOT NULL,
    failed_triggers integer NOT NULL,
    table_id integer NOT NULL
);


--
-- Name: database_tablewebhook_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_tablewebhook ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_tablewebhook_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_tablewebhookcall; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_tablewebhookcall (
    event_id uuid NOT NULL,
    event_type character varying(50) NOT NULL,
    called_time timestamp with time zone,
    called_url text NOT NULL,
    request text,
    response text,
    response_status integer,
    error text,
    webhook_id integer NOT NULL,
    id integer NOT NULL,
    batch_id integer,
    CONSTRAINT database_tablewebhookcall_batch_id_check CHECK ((batch_id >= 0))
);


--
-- Name: database_tablewebhookcall_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_tablewebhookcall ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_tablewebhookcall_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_tablewebhookevent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_tablewebhookevent (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    event_type character varying(50) NOT NULL,
    webhook_id integer NOT NULL
);


--
-- Name: database_tablewebhookevent_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_tablewebhookevent_fields (
    id integer NOT NULL,
    tablewebhookevent_id integer NOT NULL,
    field_id integer NOT NULL
);


--
-- Name: database_tablewebhookevent_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_tablewebhookevent_fields ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_tablewebhookevent_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_tablewebhookevent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_tablewebhookevent ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_tablewebhookevent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_tablewebhookevent_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_tablewebhookevent_views (
    id integer NOT NULL,
    tablewebhookevent_id integer NOT NULL,
    view_id integer NOT NULL
);


--
-- Name: database_tablewebhookevent_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_tablewebhookevent_views ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_tablewebhookevent_views_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_tablewebhookheader; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_tablewebhookheader (
    id integer NOT NULL,
    name text NOT NULL,
    value text NOT NULL,
    webhook_id integer NOT NULL
);


--
-- Name: database_tablewebhookheader_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_tablewebhookheader ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_tablewebhookheader_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_textfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_textfield (
    field_ptr_id integer NOT NULL,
    text_default character varying(255) NOT NULL
);


--
-- Name: database_timelineview; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_timelineview (
    view_ptr_id integer NOT NULL,
    end_date_field_id integer,
    start_date_field_id integer,
    timescale character varying(32) DEFAULT 'month'::character varying NOT NULL
);


--
-- Name: database_timelineviewfieldoptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_timelineviewfieldoptions (
    id integer NOT NULL,
    hidden boolean NOT NULL,
    "order" smallint NOT NULL,
    field_id integer NOT NULL,
    timeline_view_id integer NOT NULL
);


--
-- Name: database_timelineviewfieldoptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_timelineviewfieldoptions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_timelineviewfieldoptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_token (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    key character varying(32) NOT NULL,
    created timestamp with time zone NOT NULL,
    workspace_id integer NOT NULL,
    user_id integer NOT NULL,
    handled_calls integer NOT NULL,
    last_call timestamp with time zone,
    CONSTRAINT database_token_handled_calls_check CHECK ((handled_calls >= 0))
);


--
-- Name: database_token_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_token ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_tokenpermission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_tokenpermission (
    id integer NOT NULL,
    type character varying(6) NOT NULL,
    database_id integer,
    table_id integer,
    token_id integer NOT NULL
);


--
-- Name: database_tokenpermission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_tokenpermission ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_tokenpermission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_trashedrows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_trashedrows (
    id integer NOT NULL,
    row_ids jsonb NOT NULL,
    table_id integer NOT NULL
);


--
-- Name: database_trashedrows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_trashedrows ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_trashedrows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_urlfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_urlfield (
    field_ptr_id integer NOT NULL
);


--
-- Name: database_uuidfield; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_uuidfield (
    field_ptr_id integer NOT NULL
);


--
-- Name: database_view; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_view (
    id integer NOT NULL,
    "order" integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    table_id integer NOT NULL,
    filter_type character varying(3) NOT NULL,
    filters_disabled boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    public boolean NOT NULL,
    slug character varying(50) NOT NULL,
    public_view_password character varying(128) NOT NULL,
    trashed boolean NOT NULL,
    show_logo boolean NOT NULL,
    created_by_id integer,
    ownership_type character varying(255) NOT NULL,
    db_index_name character varying(30),
    allow_public_export boolean DEFAULT false NOT NULL,
    CONSTRAINT database_view_order_check CHECK (("order" >= 0))
);


--
-- Name: database_view_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_view ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_view_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_viewdecoration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_viewdecoration (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    value_provider_type character varying(255) NOT NULL,
    value_provider_conf jsonb NOT NULL,
    "order" smallint NOT NULL,
    view_id integer NOT NULL
);


--
-- Name: database_viewdecoration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_viewdecoration ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_viewdecoration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_viewdefaultvalue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_viewdefaultvalue (
    id integer NOT NULL,
    enabled boolean NOT NULL,
    value jsonb,
    field_type character varying(64),
    function character varying(64),
    field_id integer NOT NULL,
    view_id integer NOT NULL
);


--
-- Name: database_viewdefaultvalue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_viewdefaultvalue ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_viewdefaultvalue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_viewfilter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_viewfilter (
    id integer NOT NULL,
    type character varying(48) NOT NULL,
    value text NOT NULL,
    field_id integer NOT NULL,
    view_id integer NOT NULL,
    group_id integer
);


--
-- Name: database_viewfilter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_viewfilter ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_viewfilter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_viewfiltergroup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_viewfiltergroup (
    id integer NOT NULL,
    filter_type character varying(3) NOT NULL,
    parent_group_id integer,
    view_id integer NOT NULL
);


--
-- Name: database_viewfiltergroup_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_viewfiltergroup ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_viewfiltergroup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_viewgroupby; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_viewgroupby (
    id integer NOT NULL,
    "order" character varying(4) NOT NULL,
    field_id integer NOT NULL,
    view_id integer NOT NULL,
    width integer NOT NULL,
    type character varying(32) DEFAULT 'default'::character varying NOT NULL,
    priority smallint DEFAULT 32767 NOT NULL,
    CONSTRAINT database_viewgroupby_priority_check CHECK ((priority >= 0)),
    CONSTRAINT database_viewgroupby_width_check CHECK ((width >= 0))
);


--
-- Name: database_viewgroupby_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_viewgroupby ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_viewgroupby_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_viewrows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_viewrows (
    id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    row_ids integer[] NOT NULL,
    view_id integer NOT NULL
);


--
-- Name: database_viewrows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_viewrows ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_viewrows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_viewsort; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_viewsort (
    id integer NOT NULL,
    "order" character varying(4) NOT NULL,
    field_id integer NOT NULL,
    view_id integer NOT NULL,
    type character varying(32) DEFAULT 'default'::character varying NOT NULL,
    priority smallint DEFAULT 32767 NOT NULL,
    CONSTRAINT database_viewsort_priority_check CHECK ((priority >= 0))
);


--
-- Name: database_viewsort_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_viewsort ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_viewsort_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_viewsubscription; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_viewsubscription (
    id integer NOT NULL,
    subscriber_id integer NOT NULL,
    subscriber_content_type_id integer NOT NULL,
    view_id integer NOT NULL,
    CONSTRAINT database_viewsubscription_subscriber_id_check CHECK ((subscriber_id >= 0))
);


--
-- Name: database_viewsubscription_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.database_viewsubscription ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.database_viewsubscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.django_content_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


--
-- Name: health_check_db_testmodel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.health_check_db_testmodel (
    id integer NOT NULL,
    title character varying(128) NOT NULL
);


--
-- Name: health_check_db_testmodel_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.health_check_db_testmodel ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.health_check_db_testmodel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: integrations_aiagentservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_aiagentservice (
    service_ptr_id integer NOT NULL,
    ai_generative_ai_type character varying(32),
    ai_generative_ai_model character varying(128),
    ai_output_type character varying(32) NOT NULL,
    ai_temperature double precision,
    ai_prompt text,
    ai_choices jsonb NOT NULL
);


--
-- Name: integrations_aiintegration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_aiintegration (
    integration_ptr_id integer NOT NULL,
    ai_settings jsonb NOT NULL
);


--
-- Name: integrations_corecsvfilereaderservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_corecsvfilereaderservice (
    service_ptr_id integer NOT NULL,
    file text,
    csv text,
    input_type character varying(32) NOT NULL,
    separator character varying(1) NOT NULL,
    encoding character varying(32) NOT NULL,
    first_line_is_header boolean NOT NULL
);


--
-- Name: integrations_corehttprequestservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_corehttprequestservice (
    service_ptr_id integer NOT NULL,
    http_method character varying(10) NOT NULL,
    url text,
    body_type character varying(20) NOT NULL,
    body_content text,
    timeout integer NOT NULL,
    CONSTRAINT integrations_corehttprequestservice_timeout_check CHECK ((timeout >= 0))
);


--
-- Name: integrations_corehttptriggerservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_corehttptriggerservice (
    service_ptr_id integer NOT NULL,
    uid uuid NOT NULL,
    exclude_get boolean NOT NULL,
    is_public boolean NOT NULL
);


--
-- Name: integrations_coreiteratorservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_coreiteratorservice (
    service_ptr_id integer NOT NULL,
    source text
);


--
-- Name: integrations_coremanualtriggerservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_coremanualtriggerservice (
    service_ptr_id integer NOT NULL
);


--
-- Name: integrations_coreperiodicservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_coreperiodicservice (
    service_ptr_id integer NOT NULL,
    last_periodic_run timestamp with time zone,
    "interval" character varying(10),
    minute smallint NOT NULL,
    hour smallint NOT NULL,
    day_of_week smallint NOT NULL,
    day_of_month smallint NOT NULL,
    next_run_at timestamp with time zone,
    CONSTRAINT integrations_coreperiodicservice_day_of_month_check CHECK ((day_of_month >= 0)),
    CONSTRAINT integrations_coreperiodicservice_day_of_week_check CHECK ((day_of_week >= 0)),
    CONSTRAINT integrations_coreperiodicservice_hour_check CHECK ((hour >= 0)),
    CONSTRAINT integrations_coreperiodicservice_minute_check CHECK ((minute >= 0))
);


--
-- Name: integrations_corerouterservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_corerouterservice (
    service_ptr_id integer NOT NULL,
    default_edge_label character varying(75) NOT NULL
);


--
-- Name: integrations_corerouterserviceedge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_corerouterserviceedge (
    id integer NOT NULL,
    uid uuid NOT NULL,
    label character varying(75) NOT NULL,
    "order" numeric(40,20) NOT NULL,
    condition text,
    service_id integer NOT NULL
);


--
-- Name: integrations_corerouterserviceedge_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.integrations_corerouterserviceedge ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.integrations_corerouterserviceedge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: integrations_coresmtpemailservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_coresmtpemailservice (
    service_ptr_id integer NOT NULL,
    from_email text,
    from_name text,
    to_emails text,
    cc_emails text,
    bcc_emails text,
    subject text,
    body_type character varying(10) NOT NULL,
    body text,
    use_instance_smtp_settings boolean DEFAULT false NOT NULL
);


--
-- Name: integrations_corestartworkflowservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_corestartworkflowservice (
    service_ptr_id integer NOT NULL,
    workflow_id integer
);


--
-- Name: integrations_httpformdata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_httpformdata (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    value text,
    service_id integer NOT NULL
);


--
-- Name: integrations_httpformdata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.integrations_httpformdata ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.integrations_httpformdata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: integrations_httpheader; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_httpheader (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    value text,
    service_id integer NOT NULL
);


--
-- Name: integrations_httpheader_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.integrations_httpheader ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.integrations_httpheader_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: integrations_httpqueryparam; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_httpqueryparam (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    value text,
    service_id integer NOT NULL
);


--
-- Name: integrations_httpqueryparam_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.integrations_httpqueryparam ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.integrations_httpqueryparam_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: integrations_localbaserowaggregaterows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowaggregaterows (
    service_ptr_id integer NOT NULL,
    search_query text,
    filter_type character varying(3) NOT NULL,
    aggregation_type character varying(48) NOT NULL,
    field_id integer,
    table_id integer,
    view_id integer
);


--
-- Name: integrations_localbaserowcreaterows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowcreaterows (
    service_ptr_id integer NOT NULL,
    rows text,
    table_id integer
);


--
-- Name: integrations_localbaserowdeleterow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowdeleterow (
    service_ptr_id integer NOT NULL,
    row_id text,
    table_id integer
);


--
-- Name: integrations_localbaserowfieldsupdated; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowfieldsupdated (
    service_ptr_id integer NOT NULL,
    table_id integer
);


--
-- Name: integrations_localbaserowfieldsupdated_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowfieldsupdated_fields (
    id integer NOT NULL,
    localbaserowfieldsupdated_id integer NOT NULL,
    field_id integer NOT NULL
);


--
-- Name: integrations_localbaserowfieldsupdated_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.integrations_localbaserowfieldsupdated_fields ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.integrations_localbaserowfieldsupdated_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: integrations_localbaserowgetrow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowgetrow (
    service_ptr_id integer NOT NULL,
    row_id text,
    view_id integer,
    search_query text,
    table_id integer,
    filter_type character varying(3) NOT NULL
);


--
-- Name: integrations_localbaserowintegration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowintegration (
    integration_ptr_id integer NOT NULL,
    authorized_user_id integer
);


--
-- Name: integrations_localbaserowlistrows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowlistrows (
    service_ptr_id integer NOT NULL,
    view_id integer,
    search_query text,
    table_id integer,
    filter_type character varying(3) NOT NULL,
    default_result_count integer DEFAULT 20 NOT NULL,
    CONSTRAINT integrations_localbaserowlistrows_default_result_count_check CHECK ((default_result_count >= 0))
);


--
-- Name: integrations_localbaserowrowscreated; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowrowscreated (
    service_ptr_id integer NOT NULL,
    table_id integer
);


--
-- Name: integrations_localbaserowrowsdeleted; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowrowsdeleted (
    service_ptr_id integer NOT NULL,
    table_id integer
);


--
-- Name: integrations_localbaserowrowsupdated; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowrowsupdated (
    service_ptr_id integer NOT NULL,
    table_id integer
);


--
-- Name: integrations_localbaserowtableservicefieldmapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowtableservicefieldmapping (
    id integer NOT NULL,
    value text,
    field_id integer NOT NULL,
    service_id integer NOT NULL,
    enabled boolean
);


--
-- Name: integrations_localbaserowtableservicefieldmapping_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.integrations_localbaserowtableservicefieldmapping ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.integrations_localbaserowtableservicefieldmapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: integrations_localbaserowtableservicefilter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowtableservicefilter (
    id integer NOT NULL,
    type character varying(48) NOT NULL,
    value text,
    field_id integer NOT NULL,
    service_id integer NOT NULL,
    "order" integer NOT NULL,
    value_is_formula boolean NOT NULL,
    CONSTRAINT integrations_localbaserowtableservicefilter_order_check CHECK (("order" >= 0))
);


--
-- Name: integrations_localbaserowtableservicefilter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.integrations_localbaserowtableservicefilter ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.integrations_localbaserowtableservicefilter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: integrations_localbaserowtableservicesort; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowtableservicesort (
    id integer NOT NULL,
    "order" integer NOT NULL,
    field_id integer NOT NULL,
    service_id integer NOT NULL,
    order_by character varying(4) NOT NULL,
    CONSTRAINT integrations_localbaserowtableservicesort_order_check CHECK (("order" >= 0))
);


--
-- Name: integrations_localbaserowtableservicesort_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.integrations_localbaserowtableservicesort ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.integrations_localbaserowtableservicesort_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: integrations_localbaserowupdaterows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowupdaterows (
    service_ptr_id integer NOT NULL,
    rows text,
    table_id integer
);


--
-- Name: integrations_localbaserowupsertrow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_localbaserowupsertrow (
    service_ptr_id integer NOT NULL,
    table_id integer,
    row_id text
);


--
-- Name: integrations_slackbotintegration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_slackbotintegration (
    integration_ptr_id integer NOT NULL,
    token character varying(255) NOT NULL
);


--
-- Name: integrations_slackwritemessageservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_slackwritemessageservice (
    service_ptr_id integer NOT NULL,
    channel character varying(80) NOT NULL,
    text text
);


--
-- Name: integrations_smtpintegration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations_smtpintegration (
    integration_ptr_id integer NOT NULL,
    host character varying(255) NOT NULL,
    port integer NOT NULL,
    use_tls boolean NOT NULL,
    username character varying(255),
    password character varying(255),
    CONSTRAINT integrations_smtpintegration_port_check CHECK ((port >= 0))
);


--
-- Name: ws_realtime_events; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.ws_realtime_events (
    id bigint NOT NULL,
    channel_group text NOT NULL,
    payload jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: ws_realtime_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ws_realtime_events ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ws_realtime_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: database_linkrowfield link_row_relation_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_linkrowfield ALTER COLUMN link_row_relation_id SET DEFAULT nextval('public.database_linkrowfield_link_row_relation_id_seq'::regclass);


--
-- Name: baserow_premium_aifieldscheduledupdate ai_field_id_row_id_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_aifieldscheduledupdate
    ADD CONSTRAINT ai_field_id_row_id_uniq UNIQUE (field_id, row_id);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);


--
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);


--
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: automation_aiagentactionnode automation_aiagentactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_aiagentactionnode
    ADD CONSTRAINT automation_aiagentactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_automation automation_automation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automation
    ADD CONSTRAINT automation_automation_pkey PRIMARY KEY (application_ptr_id);


--
-- Name: automation_automationnoderesult automation_automationnod_node_history_id_iteratio_291f8a16_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationnoderesult
    ADD CONSTRAINT automation_automationnod_node_history_id_iteratio_291f8a16_uniq UNIQUE (node_history_id, iteration_path);


--
-- Name: automation_automationnode automation_automationnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationnode
    ADD CONSTRAINT automation_automationnode_pkey PRIMARY KEY (id);


--
-- Name: automation_automationnode automation_automationnode_service_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationnode
    ADD CONSTRAINT automation_automationnode_service_id_key UNIQUE (service_id);


--
-- Name: automation_automationnodehistory automation_automationnodehistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationnodehistory
    ADD CONSTRAINT automation_automationnodehistory_pkey PRIMARY KEY (id);


--
-- Name: automation_automationnoderesult automation_automationnoderesult_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationnoderesult
    ADD CONSTRAINT automation_automationnoderesult_pkey PRIMARY KEY (id);


--
-- Name: automation_automationworkflow_notification_recipients automation_automationwor_automationworkflow_id_us_8c9a97ba_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationworkflow_notification_recipients
    ADD CONSTRAINT automation_automationwor_automationworkflow_id_us_8c9a97ba_uniq UNIQUE (automationworkflow_id, user_id);


--
-- Name: automation_automationworkflow_notification_recipients automation_automationworkflow_notification_recipients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationworkflow_notification_recipients
    ADD CONSTRAINT automation_automationworkflow_notification_recipients_pkey PRIMARY KEY (id);


--
-- Name: automation_automationworkflow automation_automationworkflow_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationworkflow
    ADD CONSTRAINT automation_automationworkflow_pkey PRIMARY KEY (id);


--
-- Name: automation_automationworkflowhistory automation_automationworkflowhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationworkflowhistory
    ADD CONSTRAINT automation_automationworkflowhistory_pkey PRIMARY KEY (id);


--
-- Name: automation_corecsvfilereaderactionnode automation_corecsvfilereaderactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_corecsvfilereaderactionnode
    ADD CONSTRAINT automation_corecsvfilereaderactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_corehttprequestactionnode automation_corehttprequestactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_corehttprequestactionnode
    ADD CONSTRAINT automation_corehttprequestactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_corehttptriggernode automation_corehttptriggernode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_corehttptriggernode
    ADD CONSTRAINT automation_corehttptriggernode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_coreiteratoractionnode automation_coreiteratoractionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_coreiteratoractionnode
    ADD CONSTRAINT automation_coreiteratoractionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_coremanualtriggernode automation_coremanualtriggernode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_coremanualtriggernode
    ADD CONSTRAINT automation_coremanualtriggernode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_coreperiodictriggernode automation_coreperiodictriggernode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_coreperiodictriggernode
    ADD CONSTRAINT automation_coreperiodictriggernode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_corerouteractionnode automation_corerouteractionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_corerouteractionnode
    ADD CONSTRAINT automation_corerouteractionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_coresmtpemailactionnode automation_coresmtpemailactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_coresmtpemailactionnode
    ADD CONSTRAINT automation_coresmtpemailactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_corestartworkflowactionnode automation_corestartworkflowactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_corestartworkflowactionnode
    ADD CONSTRAINT automation_corestartworkflowactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_duplicateautomationworkflowjob automation_duplicateautomatio_duplicated_automation_workflo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_duplicateautomationworkflowjob
    ADD CONSTRAINT automation_duplicateautomatio_duplicated_automation_workflo_key UNIQUE (duplicated_automation_workflow_id);


--
-- Name: automation_duplicateautomationworkflowjob automation_duplicateautomationworkflowjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_duplicateautomationworkflowjob
    ADD CONSTRAINT automation_duplicateautomationworkflowjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: automation_localbaserowaggregaterowsactionnode automation_localbaserowaggregaterowsactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowaggregaterowsactionnode
    ADD CONSTRAINT automation_localbaserowaggregaterowsactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_localbaserowcreaterowactionnode automation_localbaserowcreaterowactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowcreaterowactionnode
    ADD CONSTRAINT automation_localbaserowcreaterowactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_localbaserowcreaterowsactionnode automation_localbaserowcreaterowsactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowcreaterowsactionnode
    ADD CONSTRAINT automation_localbaserowcreaterowsactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_localbaserowdeleterowactionnode automation_localbaserowdeleterowactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowdeleterowactionnode
    ADD CONSTRAINT automation_localbaserowdeleterowactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_localbaserowfieldsupdatedtriggernode automation_localbaserowfieldsupdatedtriggernode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowfieldsupdatedtriggernode
    ADD CONSTRAINT automation_localbaserowfieldsupdatedtriggernode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_localbaserowgetrowactionnode automation_localbaserowgetrowactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowgetrowactionnode
    ADD CONSTRAINT automation_localbaserowgetrowactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_localbaserowlistrowsactionnode automation_localbaserowlistrowsactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowlistrowsactionnode
    ADD CONSTRAINT automation_localbaserowlistrowsactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_localbaserowrowscreatedtriggernode automation_localbaserowrowscreatedtriggernode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowrowscreatedtriggernode
    ADD CONSTRAINT automation_localbaserowrowscreatedtriggernode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_localbaserowrowsdeletedtriggernode automation_localbaserowrowsdeletedtriggernode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowrowsdeletedtriggernode
    ADD CONSTRAINT automation_localbaserowrowsdeletedtriggernode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_localbaserowrowsupdatedtriggernode automation_localbaserowrowsupdatedtriggernode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowrowsupdatedtriggernode
    ADD CONSTRAINT automation_localbaserowrowsupdatedtriggernode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_localbaserowupdaterowactionnode automation_localbaserowupdaterowactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowupdaterowactionnode
    ADD CONSTRAINT automation_localbaserowupdaterowactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_localbaserowupdaterowsactionnode automation_localbaserowupdaterowsactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowupdaterowsactionnode
    ADD CONSTRAINT automation_localbaserowupdaterowsactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: automation_publishautomationworkflowjob automation_publishautomationworkflowjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_publishautomationworkflowjob
    ADD CONSTRAINT automation_publishautomationworkflowjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: automation_slackwritemessageactionnode automation_slackwritemessageactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_slackwritemessageactionnode
    ADD CONSTRAINT automation_slackwritemessageactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: baserow_enterprise_assistantchat baserow_enterprise_assistantchat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_assistantchat
    ADD CONSTRAINT baserow_enterprise_assistantchat_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_assistantchat baserow_enterprise_assistantchat_uuid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_assistantchat
    ADD CONSTRAINT baserow_enterprise_assistantchat_uuid_key UNIQUE (uuid);


--
-- Name: baserow_enterprise_assistantchatmessage baserow_enterprise_assistantchatmessage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_assistantchatmessage
    ADD CONSTRAINT baserow_enterprise_assistantchatmessage_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_assistantchatprediction baserow_enterprise_assistantchatprediction_ai_response_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_assistantchatprediction
    ADD CONSTRAINT baserow_enterprise_assistantchatprediction_ai_response_id_key UNIQUE (ai_response_id);


--
-- Name: baserow_enterprise_assistantchatprediction baserow_enterprise_assistantchatprediction_human_message_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_assistantchatprediction
    ADD CONSTRAINT baserow_enterprise_assistantchatprediction_human_message_id_key UNIQUE (human_message_id);


--
-- Name: baserow_enterprise_assistantchatprediction baserow_enterprise_assistantchatprediction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_assistantchatprediction
    ADD CONSTRAINT baserow_enterprise_assistantchatprediction_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_auditlogentry baserow_enterprise_auditlogentry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_auditlogentry
    ADD CONSTRAINT baserow_enterprise_auditlogentry_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_auditlogexportjob baserow_enterprise_auditlogexportjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_auditlogexportjob
    ADD CONSTRAINT baserow_enterprise_auditlogexportjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: baserow_enterprise_authformelement baserow_enterprise_authformelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_authformelement
    ADD CONSTRAINT baserow_enterprise_authformelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: baserow_enterprise_buildercustomcode baserow_enterprise_buildercustomcode_builder_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_buildercustomcode
    ADD CONSTRAINT baserow_enterprise_buildercustomcode_builder_id_key UNIQUE (builder_id);


--
-- Name: baserow_enterprise_buildercustomcode baserow_enterprise_buildercustomcode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_buildercustomcode
    ADD CONSTRAINT baserow_enterprise_buildercustomcode_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_buildercustomscript baserow_enterprise_buildercustomscript_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_buildercustomscript
    ADD CONSTRAINT baserow_enterprise_buildercustomscript_pkey PRIMARY KEY (id);


--
-- Name: baserow_premium_chartwidget baserow_enterprise_chartwidget_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_chartwidget
    ADD CONSTRAINT baserow_enterprise_chartwidget_pkey PRIMARY KEY (widget_ptr_id);


--
-- Name: baserow_enterprise_corecodeactionnode baserow_enterprise_corecodeactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corecodeactionnode
    ADD CONSTRAINT baserow_enterprise_corecodeactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: baserow_enterprise_corecodeservice baserow_enterprise_corecodeservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corecodeservice
    ADD CONSTRAINT baserow_enterprise_corecodeservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: baserow_enterprise_corecodeserviceinjection baserow_enterprise_corecodeserviceinjection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corecodeserviceinjection
    ADD CONSTRAINT baserow_enterprise_corecodeserviceinjection_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_corecodeworkflowaction baserow_enterprise_corecodeworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corecodeworkflowaction
    ADD CONSTRAINT baserow_enterprise_corecodeworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: baserow_enterprise_corexlsfilereaderactionnode baserow_enterprise_corexlsfilereaderactionnode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corexlsfilereaderactionnode
    ADD CONSTRAINT baserow_enterprise_corexlsfilereaderactionnode_pkey PRIMARY KEY (automationnode_ptr_id);


--
-- Name: baserow_enterprise_corexlsfilereaderservice baserow_enterprise_corexlsfilereaderservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corexlsfilereaderservice
    ADD CONSTRAINT baserow_enterprise_corexlsfilereaderservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: baserow_enterprise_corexlsfilereaderworkflowaction baserow_enterprise_corexlsfilereaderworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corexlsfilereaderworkflowaction
    ADD CONSTRAINT baserow_enterprise_corexlsfilereaderworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: baserow_enterprise_datascan_workspaces baserow_enterprise_datas_datascan_id_workspace_id_c222266d_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascan_workspaces
    ADD CONSTRAINT baserow_enterprise_datas_datascan_id_workspace_id_c222266d_uniq UNIQUE (datascan_id, workspace_id);


--
-- Name: baserow_enterprise_datascanresult baserow_enterprise_datas_scan_id_table_id_row_id__9627ccd3_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascanresult
    ADD CONSTRAINT baserow_enterprise_datas_scan_id_table_id_row_id__9627ccd3_uniq UNIQUE (scan_id, table_id, row_id, field_id);


--
-- Name: baserow_enterprise_datascan baserow_enterprise_datascan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascan
    ADD CONSTRAINT baserow_enterprise_datascan_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_datascan_workspaces baserow_enterprise_datascan_workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascan_workspaces
    ADD CONSTRAINT baserow_enterprise_datascan_workspaces_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_datascanlistitem baserow_enterprise_datascanlistitem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascanlistitem
    ADD CONSTRAINT baserow_enterprise_datascanlistitem_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_datascanresult baserow_enterprise_datascanresult_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascanresult
    ADD CONSTRAINT baserow_enterprise_datascanresult_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_datascanresultexportjob baserow_enterprise_datascanresultexportjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascanresultexportjob
    ADD CONSTRAINT baserow_enterprise_datascanresultexportjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: baserow_enterprise_datedependency baserow_enterprise_datedependency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datedependency
    ADD CONSTRAINT baserow_enterprise_datedependency_pkey PRIMARY KEY (fieldrule_ptr_id);


--
-- Name: baserow_enterprise_facebookauthprovidermodel baserow_enterprise_facebookauthprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_facebookauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_facebookauthprovidermodel_pkey PRIMARY KEY (authprovidermodel_ptr_id);


--
-- Name: baserow_enterprise_fieldpermissions baserow_enterprise_fieldpermissions_field_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_fieldpermissions
    ADD CONSTRAINT baserow_enterprise_fieldpermissions_field_id_key UNIQUE (field_id);


--
-- Name: baserow_enterprise_fieldpermissions baserow_enterprise_fieldpermissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_fieldpermissions
    ADD CONSTRAINT baserow_enterprise_fieldpermissions_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_fileinputelement baserow_enterprise_fileinputelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_fileinputelement
    ADD CONSTRAINT baserow_enterprise_fileinputelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: baserow_enterprise_githubauthprovidermodel baserow_enterprise_githubauthprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_githubauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_githubauthprovidermodel_pkey PRIMARY KEY (authprovidermodel_ptr_id);


--
-- Name: baserow_enterprise_githubissuesdatasync baserow_enterprise_githubissuesdatasync_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_githubissuesdatasync
    ADD CONSTRAINT baserow_enterprise_githubissuesdatasync_pkey PRIMARY KEY (datasync_ptr_id);


--
-- Name: baserow_enterprise_gitlabauthprovidermodel baserow_enterprise_gitlabauthprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_gitlabauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_gitlabauthprovidermodel_pkey PRIMARY KEY (authprovidermodel_ptr_id);


--
-- Name: baserow_enterprise_gitlabissuesdatasync baserow_enterprise_gitlabissuesdatasync_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_gitlabissuesdatasync
    ADD CONSTRAINT baserow_enterprise_gitlabissuesdatasync_pkey PRIMARY KEY (datasync_ptr_id);


--
-- Name: baserow_enterprise_googleauthprovidermodel baserow_enterprise_googleauthprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_googleauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_googleauthprovidermodel_pkey PRIMARY KEY (authprovidermodel_ptr_id);


--
-- Name: baserow_enterprise_hubspotcontactsdatasync baserow_enterprise_hubspotcontactsdatasync_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_hubspotcontactsdatasync
    ADD CONSTRAINT baserow_enterprise_hubspotcontactsdatasync_pkey PRIMARY KEY (datasync_ptr_id);


--
-- Name: baserow_enterprise_jiraissuesdatasync baserow_enterprise_jiraissuesdatasync_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_jiraissuesdatasync
    ADD CONSTRAINT baserow_enterprise_jiraissuesdatasync_pkey PRIMARY KEY (datasync_ptr_id);


--
-- Name: baserow_enterprise_knowledgebasecategory baserow_enterprise_knowledgebasecategory_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_knowledgebasecategory
    ADD CONSTRAINT baserow_enterprise_knowledgebasecategory_name_key UNIQUE (name);


--
-- Name: baserow_enterprise_knowledgebasecategory baserow_enterprise_knowledgebasecategory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_knowledgebasecategory
    ADD CONSTRAINT baserow_enterprise_knowledgebasecategory_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_knowledgebasechunk baserow_enterprise_knowledgebasechunk_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_knowledgebasechunk
    ADD CONSTRAINT baserow_enterprise_knowledgebasechunk_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_knowledgebasedocument baserow_enterprise_knowledgebasedocument_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_knowledgebasedocument
    ADD CONSTRAINT baserow_enterprise_knowledgebasedocument_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_knowledgebasedocument baserow_enterprise_knowledgebasedocument_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_knowledgebasedocument
    ADD CONSTRAINT baserow_enterprise_knowledgebasedocument_slug_key UNIQUE (slug);


--
-- Name: baserow_premium_localbaserowgroupedaggregaterows baserow_enterprise_localbaserowgroupedaggregaterows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowgroupedaggregaterows
    ADD CONSTRAINT baserow_enterprise_localbaserowgroupedaggregaterows_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: baserow_enterprise_localbaserowpasswordappauthprovider baserow_enterprise_localbaserowpasswordappauthprovider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowpasswordappauthprovider
    ADD CONSTRAINT baserow_enterprise_localbaserowpasswordappauthprovider_pkey PRIMARY KEY (appauthprovider_ptr_id);


--
-- Name: baserow_enterprise_localbaserowtabledatasync baserow_enterprise_localbaserowtabledatasync_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowtabledatasync
    ADD CONSTRAINT baserow_enterprise_localbaserowtabledatasync_pkey PRIMARY KEY (datasync_ptr_id);


--
-- Name: baserow_premium_localbaserowtableserviceaggregationgroupby baserow_enterprise_localbaserowtableserviceaggregationgrou_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowtableserviceaggregationgroupby
    ADD CONSTRAINT baserow_enterprise_localbaserowtableserviceaggregationgrou_pkey PRIMARY KEY (id);


--
-- Name: baserow_premium_localbaserowtableserviceaggregationseries baserow_enterprise_localbaserowtableserviceaggregationseri_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowtableserviceaggregationseries
    ADD CONSTRAINT baserow_enterprise_localbaserowtableserviceaggregationseri_pkey PRIMARY KEY (id);


--
-- Name: baserow_premium_localbaserowtableserviceaggregationsortby baserow_enterprise_localbaserowtableserviceaggregationsort_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowtableserviceaggregationsortby
    ADD CONSTRAINT baserow_enterprise_localbaserowtableserviceaggregationsort_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_localbaserowusersource baserow_enterprise_localbaserowusersource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowusersource
    ADD CONSTRAINT baserow_enterprise_localbaserowusersource_pkey PRIMARY KEY (usersource_ptr_id);


--
-- Name: baserow_enterprise_openidconnectappauthprovidermodel baserow_enterprise_openidconnectappauthprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_openidconnectappauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_openidconnectappauthprovidermodel_pkey PRIMARY KEY (appauthprovider_ptr_id);


--
-- Name: baserow_enterprise_openidconnectauthprovidermodel baserow_enterprise_openidconnectauthprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_openidconnectauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_openidconnectauthprovidermodel_pkey PRIMARY KEY (authprovidermodel_ptr_id);


--
-- Name: baserow_enterprise_periodicdatasyncinterval baserow_enterprise_periodicdatasyncinterval_data_sync_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_periodicdatasyncinterval
    ADD CONSTRAINT baserow_enterprise_periodicdatasyncinterval_data_sync_id_key UNIQUE (data_sync_id);


--
-- Name: baserow_enterprise_periodicdatasyncinterval baserow_enterprise_periodicdatasyncinterval_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_periodicdatasyncinterval
    ADD CONSTRAINT baserow_enterprise_periodicdatasyncinterval_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_role_operations baserow_enterprise_role__role_id_operation_id_77cdef4a_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_role_operations
    ADD CONSTRAINT baserow_enterprise_role__role_id_operation_id_77cdef4a_uniq UNIQUE (role_id, operation_id);


--
-- Name: baserow_enterprise_role_operations baserow_enterprise_role_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_role_operations
    ADD CONSTRAINT baserow_enterprise_role_operations_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_role baserow_enterprise_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_role
    ADD CONSTRAINT baserow_enterprise_role_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_role baserow_enterprise_role_uid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_role
    ADD CONSTRAINT baserow_enterprise_role_uid_key UNIQUE (uid);


--
-- Name: baserow_enterprise_roleassignment baserow_enterprise_roleassignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_roleassignment
    ADD CONSTRAINT baserow_enterprise_roleassignment_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_samlappauthprovidermodel baserow_enterprise_samlappauthprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_samlappauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_samlappauthprovidermodel_pkey PRIMARY KEY (appauthprovider_ptr_id);


--
-- Name: baserow_enterprise_samlauthprovidermodel baserow_enterprise_samlauthprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_samlauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_samlauthprovidermodel_pkey PRIMARY KEY (authprovidermodel_ptr_id);


--
-- Name: baserow_enterprise_team baserow_enterprise_team_name_group_id_8634b986_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_team
    ADD CONSTRAINT baserow_enterprise_team_name_group_id_8634b986_uniq UNIQUE (name, workspace_id);


--
-- Name: baserow_enterprise_team baserow_enterprise_team_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_team
    ADD CONSTRAINT baserow_enterprise_team_pkey PRIMARY KEY (id);


--
-- Name: baserow_enterprise_teamsubject baserow_enterprise_teamsubject_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_teamsubject
    ADD CONSTRAINT baserow_enterprise_teamsubject_pkey PRIMARY KEY (id);


--
-- Name: baserow_premium_aifield baserow_premium_aifield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_aifield
    ADD CONSTRAINT baserow_premium_aifield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: baserow_premium_aifieldscheduledupdate baserow_premium_aifieldscheduledupdate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_aifieldscheduledupdate
    ADD CONSTRAINT baserow_premium_aifieldscheduledupdate_pkey PRIMARY KEY (id);


--
-- Name: baserow_premium_chartseriesconfig baserow_premium_chartseriesconfig_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_chartseriesconfig
    ADD CONSTRAINT baserow_premium_chartseriesconfig_pkey PRIMARY KEY (id);


--
-- Name: baserow_premium_generateaivaluesjob baserow_premium_generateaivaluesjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_generateaivaluesjob
    ADD CONSTRAINT baserow_premium_generateaivaluesjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: baserow_premium_license baserow_premium_license_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_license
    ADD CONSTRAINT baserow_premium_license_pkey PRIMARY KEY (id);


--
-- Name: baserow_premium_licenseuser baserow_premium_licenseuser_license_id_user_id_d0a8e449_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_licenseuser
    ADD CONSTRAINT baserow_premium_licenseuser_license_id_user_id_d0a8e449_uniq UNIQUE (license_id, user_id);


--
-- Name: baserow_premium_licenseuser baserow_premium_licenseuser_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_licenseuser
    ADD CONSTRAINT baserow_premium_licenseuser_pkey PRIMARY KEY (id);


--
-- Name: baserow_premium_piechartseriesconfig baserow_premium_piechartseriesconfig_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_piechartseriesconfig
    ADD CONSTRAINT baserow_premium_piechartseriesconfig_pkey PRIMARY KEY (id);


--
-- Name: baserow_premium_piechartwidget baserow_premium_piechartwidget_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_piechartwidget
    ADD CONSTRAINT baserow_premium_piechartwidget_pkey PRIMARY KEY (widget_ptr_id);


--
-- Name: baserow_premium_rowcommentsnotificationmode baserow_premium_rowcomme_table_id_row_id_user_id_67f34148_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_rowcommentsnotificationmode
    ADD CONSTRAINT baserow_premium_rowcomme_table_id_row_id_user_id_67f34148_uniq UNIQUE (table_id, row_id, user_id);


--
-- Name: baserow_premium_rowcommentsnotificationmode baserow_premium_rowcommentsnotificationmode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_rowcommentsnotificationmode
    ADD CONSTRAINT baserow_premium_rowcommentsnotificationmode_pkey PRIMARY KEY (id);


--
-- Name: builder_aiagentworkflowaction builder_aiagentworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_aiagentworkflowaction
    ADD CONSTRAINT builder_aiagentworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_builder builder_builder_login_page_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_builder
    ADD CONSTRAINT builder_builder_login_page_id_key UNIQUE (login_page_id);


--
-- Name: builder_builder builder_builder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_builder
    ADD CONSTRAINT builder_builder_pkey PRIMARY KEY (application_ptr_id);


--
-- Name: builder_builderworkflowaction builder_builderworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_builderworkflowaction
    ADD CONSTRAINT builder_builderworkflowaction_pkey PRIMARY KEY (id);


--
-- Name: builder_buttonelement builder_buttonelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_buttonelement
    ADD CONSTRAINT builder_buttonelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_buttonthemeconfigblock builder_buttonthemeconfigblock_builder_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_buttonthemeconfigblock
    ADD CONSTRAINT builder_buttonthemeconfigblock_builder_id_key UNIQUE (builder_id);


--
-- Name: builder_buttonthemeconfigblock builder_buttonthemeconfigblock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_buttonthemeconfigblock
    ADD CONSTRAINT builder_buttonthemeconfigblock_pkey PRIMARY KEY (id);


--
-- Name: builder_checkboxelement builder_checkboxelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_checkboxelement
    ADD CONSTRAINT builder_checkboxelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_collectionelementpropertyoptions builder_collectionelemen_element_id_schema_proper_778d4dd7_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_collectionelementpropertyoptions
    ADD CONSTRAINT builder_collectionelemen_element_id_schema_proper_778d4dd7_uniq UNIQUE (element_id, schema_property);


--
-- Name: builder_collectionelementpropertyoptions builder_collectionelementpropertyoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_collectionelementpropertyoptions
    ADD CONSTRAINT builder_collectionelementpropertyoptions_pkey PRIMARY KEY (id);


--
-- Name: builder_collectionfield builder_collectionfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_collectionfield
    ADD CONSTRAINT builder_collectionfield_pkey PRIMARY KEY (id);


--
-- Name: builder_colorthemeconfigblock builder_colorthemeconfigblock_builder_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_colorthemeconfigblock
    ADD CONSTRAINT builder_colorthemeconfigblock_builder_id_key UNIQUE (builder_id);


--
-- Name: builder_colorthemeconfigblock builder_colorthemeconfigblock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_colorthemeconfigblock
    ADD CONSTRAINT builder_colorthemeconfigblock_pkey PRIMARY KEY (id);


--
-- Name: builder_columnelement builder_columnelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_columnelement
    ADD CONSTRAINT builder_columnelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_corecsvfilereaderworkflowaction builder_corecsvfilereaderworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_corecsvfilereaderworkflowaction
    ADD CONSTRAINT builder_corecsvfilereaderworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_corehttprequestworkflowaction builder_corehttprequestworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_corehttprequestworkflowaction
    ADD CONSTRAINT builder_corehttprequestworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_coresmtpemailworkflowaction builder_coresmtpemailworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_coresmtpemailworkflowaction
    ADD CONSTRAINT builder_coresmtpemailworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_corestartworkflowworkflowaction builder_corestartworkflowworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_corestartworkflowworkflowaction
    ADD CONSTRAINT builder_corestartworkflowworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_customdomain builder_customdomain_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_customdomain
    ADD CONSTRAINT builder_customdomain_pkey PRIMARY KEY (domain_ptr_id);


--
-- Name: builder_datasource builder_datasource_page_id_name_55e06489_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_datasource
    ADD CONSTRAINT builder_datasource_page_id_name_55e06489_uniq UNIQUE (page_id, name);


--
-- Name: builder_datasource builder_datasource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_datasource
    ADD CONSTRAINT builder_datasource_pkey PRIMARY KEY (id);


--
-- Name: builder_datasource builder_datasource_service_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_datasource
    ADD CONSTRAINT builder_datasource_service_id_key UNIQUE (service_id);


--
-- Name: builder_datetimepickerelement builder_datetimepickerelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_datetimepickerelement
    ADD CONSTRAINT builder_datetimepickerelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_domain builder_domain_domain_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_domain
    ADD CONSTRAINT builder_domain_domain_name_key UNIQUE (domain_name);


--
-- Name: builder_domain builder_domain_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_domain
    ADD CONSTRAINT builder_domain_pkey PRIMARY KEY (id);


--
-- Name: builder_domain builder_domain_published_to_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_domain
    ADD CONSTRAINT builder_domain_published_to_id_key UNIQUE (published_to_id);


--
-- Name: builder_choiceelement builder_dropdownelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_choiceelement
    ADD CONSTRAINT builder_dropdownelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_choiceelementoption builder_dropdownelementoption_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_choiceelementoption
    ADD CONSTRAINT builder_dropdownelementoption_pkey PRIMARY KEY (id);


--
-- Name: builder_duplicatepagejob builder_duplicatepagejob_duplicated_page_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_duplicatepagejob
    ADD CONSTRAINT builder_duplicatepagejob_duplicated_page_id_key UNIQUE (duplicated_page_id);


--
-- Name: builder_duplicatepagejob builder_duplicatepagejob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_duplicatepagejob
    ADD CONSTRAINT builder_duplicatepagejob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: builder_element builder_element_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_element
    ADD CONSTRAINT builder_element_pkey PRIMARY KEY (id);


--
-- Name: builder_footerelement_pages builder_footerelement_pa_footerelement_id_page_id_a313ec4f_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_footerelement_pages
    ADD CONSTRAINT builder_footerelement_pa_footerelement_id_page_id_a313ec4f_uniq UNIQUE (footerelement_id, page_id);


--
-- Name: builder_footerelement_pages builder_footerelement_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_footerelement_pages
    ADD CONSTRAINT builder_footerelement_pages_pkey PRIMARY KEY (id);


--
-- Name: builder_footerelement builder_footerelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_footerelement
    ADD CONSTRAINT builder_footerelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_formcontainerelement builder_formcontainerelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_formcontainerelement
    ADD CONSTRAINT builder_formcontainerelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_headerelement_pages builder_headerelement_pa_headerelement_id_page_id_69f31815_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_headerelement_pages
    ADD CONSTRAINT builder_headerelement_pa_headerelement_id_page_id_69f31815_uniq UNIQUE (headerelement_id, page_id);


--
-- Name: builder_headerelement_pages builder_headerelement_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_headerelement_pages
    ADD CONSTRAINT builder_headerelement_pages_pkey PRIMARY KEY (id);


--
-- Name: builder_headerelement builder_headerelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_headerelement
    ADD CONSTRAINT builder_headerelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_headingelement builder_headingelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_headingelement
    ADD CONSTRAINT builder_headingelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_iframeelement builder_iframeelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_iframeelement
    ADD CONSTRAINT builder_iframeelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_imageelement builder_imageelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_imageelement
    ADD CONSTRAINT builder_imageelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_imagethemeconfigblock builder_imagethemeconfigblock_builder_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_imagethemeconfigblock
    ADD CONSTRAINT builder_imagethemeconfigblock_builder_id_key UNIQUE (builder_id);


--
-- Name: builder_imagethemeconfigblock builder_imagethemeconfigblock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_imagethemeconfigblock
    ADD CONSTRAINT builder_imagethemeconfigblock_pkey PRIMARY KEY (id);


--
-- Name: builder_inputtextelement builder_inputtextelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_inputtextelement
    ADD CONSTRAINT builder_inputtextelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_inputthemeconfigblock builder_inputthemeconfigblock_builder_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_inputthemeconfigblock
    ADD CONSTRAINT builder_inputthemeconfigblock_builder_id_key UNIQUE (builder_id);


--
-- Name: builder_inputthemeconfigblock builder_inputthemeconfigblock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_inputthemeconfigblock
    ADD CONSTRAINT builder_inputthemeconfigblock_pkey PRIMARY KEY (id);


--
-- Name: builder_linkelement builder_linkelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_linkelement
    ADD CONSTRAINT builder_linkelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_linkthemeconfigblock builder_linkthemeconfigblock_builder_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_linkthemeconfigblock
    ADD CONSTRAINT builder_linkthemeconfigblock_builder_id_key UNIQUE (builder_id);


--
-- Name: builder_linkthemeconfigblock builder_linkthemeconfigblock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_linkthemeconfigblock
    ADD CONSTRAINT builder_linkthemeconfigblock_pkey PRIMARY KEY (id);


--
-- Name: builder_localbaserowcreaterowsworkflowaction builder_localbaserowcreaterowsworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowcreaterowsworkflowaction
    ADD CONSTRAINT builder_localbaserowcreaterowsworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_localbaserowcreaterowworkflowaction builder_localbaserowcreaterowworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowcreaterowworkflowaction
    ADD CONSTRAINT builder_localbaserowcreaterowworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_localbaserowdeleterowworkflowaction builder_localbaserowdeleterowworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowdeleterowworkflowaction
    ADD CONSTRAINT builder_localbaserowdeleterowworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_localbaserowupdaterowsworkflowaction builder_localbaserowupdaterowsworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowupdaterowsworkflowaction
    ADD CONSTRAINT builder_localbaserowupdaterowsworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_localbaserowupdaterowworkflowaction builder_localbaserowupdaterowworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowupdaterowworkflowaction
    ADD CONSTRAINT builder_localbaserowupdaterowworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_logoutworkflowaction builder_logoutworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_logoutworkflowaction
    ADD CONSTRAINT builder_logoutworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_menuelement_menu_items builder_menuelement_menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_menuelement_menu_items
    ADD CONSTRAINT builder_menuelement_menu_items_pkey PRIMARY KEY (id);


--
-- Name: builder_menuelement_menu_items builder_menuelement_menu_menuelement_id_menuiteme_bfe9dc31_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_menuelement_menu_items
    ADD CONSTRAINT builder_menuelement_menu_menuelement_id_menuiteme_bfe9dc31_uniq UNIQUE (menuelement_id, menuitemelement_id);


--
-- Name: builder_menuelement builder_menuelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_menuelement
    ADD CONSTRAINT builder_menuelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_menuitemelement builder_menuitemelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_menuitemelement
    ADD CONSTRAINT builder_menuitemelement_pkey PRIMARY KEY (id);


--
-- Name: builder_notificationworkflowaction builder_notificationworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_notificationworkflowaction
    ADD CONSTRAINT builder_notificationworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_openpageworkflowaction builder_openpageworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_openpageworkflowaction
    ADD CONSTRAINT builder_openpageworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_page builder_page_builder_id_path_1f48e2c0_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_page
    ADD CONSTRAINT builder_page_builder_id_path_1f48e2c0_uniq UNIQUE (builder_id, path);


--
-- Name: builder_page builder_page_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_page
    ADD CONSTRAINT builder_page_pkey PRIMARY KEY (id);


--
-- Name: builder_pagethemeconfigblock builder_pagethemeconfigblock_builder_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_pagethemeconfigblock
    ADD CONSTRAINT builder_pagethemeconfigblock_builder_id_key UNIQUE (builder_id);


--
-- Name: builder_pagethemeconfigblock builder_pagethemeconfigblock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_pagethemeconfigblock
    ADD CONSTRAINT builder_pagethemeconfigblock_pkey PRIMARY KEY (id);


--
-- Name: builder_textelement builder_paragraphelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_textelement
    ADD CONSTRAINT builder_paragraphelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_publishdomainjob builder_publishdomainjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_publishdomainjob
    ADD CONSTRAINT builder_publishdomainjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: builder_ratingelement builder_ratingelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_ratingelement
    ADD CONSTRAINT builder_ratingelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_ratinginputelement builder_ratinginputelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_ratinginputelement
    ADD CONSTRAINT builder_ratinginputelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_recordselectorelement builder_recordselectorelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_recordselectorelement
    ADD CONSTRAINT builder_recordselectorelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_refreshdatasourceworkflowaction builder_refreshdatasourceworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_refreshdatasourceworkflowaction
    ADD CONSTRAINT builder_refreshdatasourceworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_repeatelement builder_repeatelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_repeatelement
    ADD CONSTRAINT builder_repeatelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_simplecontainerelement builder_simplecontainerelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_simplecontainerelement
    ADD CONSTRAINT builder_simplecontainerelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_slackwritemessageworkflowaction builder_slackwritemessageworkflowaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_slackwritemessageworkflowaction
    ADD CONSTRAINT builder_slackwritemessageworkflowaction_pkey PRIMARY KEY (builderworkflowaction_ptr_id);


--
-- Name: builder_subdomain builder_subdomain_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_subdomain
    ADD CONSTRAINT builder_subdomain_pkey PRIMARY KEY (domain_ptr_id);


--
-- Name: builder_tableelement_fields builder_tableelement_fie_tableelement_id_collecti_39ad3e9c_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_tableelement_fields
    ADD CONSTRAINT builder_tableelement_fie_tableelement_id_collecti_39ad3e9c_uniq UNIQUE (tableelement_id, collectionfield_id);


--
-- Name: builder_tableelement_fields builder_tableelement_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_tableelement_fields
    ADD CONSTRAINT builder_tableelement_fields_pkey PRIMARY KEY (id);


--
-- Name: builder_tableelement builder_tableelement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_tableelement
    ADD CONSTRAINT builder_tableelement_pkey PRIMARY KEY (element_ptr_id);


--
-- Name: builder_tablethemeconfigblock builder_tablethemeconfigblock_builder_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_tablethemeconfigblock
    ADD CONSTRAINT builder_tablethemeconfigblock_builder_id_key UNIQUE (builder_id);


--
-- Name: builder_tablethemeconfigblock builder_tablethemeconfigblock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_tablethemeconfigblock
    ADD CONSTRAINT builder_tablethemeconfigblock_pkey PRIMARY KEY (id);


--
-- Name: builder_typographythemeconfigblock builder_typographythemeconfigblock_builder_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_typographythemeconfigblock
    ADD CONSTRAINT builder_typographythemeconfigblock_builder_id_key UNIQUE (builder_id);


--
-- Name: builder_typographythemeconfigblock builder_typographythemeconfigblock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_typographythemeconfigblock
    ADD CONSTRAINT builder_typographythemeconfigblock_pkey PRIMARY KEY (id);


--
-- Name: core_action core_action_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_action
    ADD CONSTRAINT core_action_pkey PRIMARY KEY (id);


--
-- Name: core_appauthprovider core_appauthprovider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_appauthprovider
    ADD CONSTRAINT core_appauthprovider_pkey PRIMARY KEY (id);


--
-- Name: core_application core_application_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_application
    ADD CONSTRAINT core_application_pkey PRIMARY KEY (id);


--
-- Name: core_authprovidermodel core_authprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_authprovidermodel
    ADD CONSTRAINT core_authprovidermodel_pkey PRIMARY KEY (id);


--
-- Name: core_authprovidermodel_users core_authprovidermodel_u_authprovidermodel_id_use_2713b441_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_authprovidermodel_users
    ADD CONSTRAINT core_authprovidermodel_u_authprovidermodel_id_use_2713b441_uniq UNIQUE (authprovidermodel_id, user_id);


--
-- Name: core_authprovidermodel_users core_authprovidermodel_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_authprovidermodel_users
    ADD CONSTRAINT core_authprovidermodel_users_pkey PRIMARY KEY (id);


--
-- Name: core_blacklistedtoken core_blacklistedtoken_hashed_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_blacklistedtoken
    ADD CONSTRAINT core_blacklistedtoken_hashed_token_key UNIQUE (hashed_token);


--
-- Name: core_blacklistedtoken core_blacklistedtoken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_blacklistedtoken
    ADD CONSTRAINT core_blacklistedtoken_pkey PRIMARY KEY (id);


--
-- Name: core_createsnapshotjob core_createsnapshotjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_createsnapshotjob
    ADD CONSTRAINT core_createsnapshotjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: core_duplicateapplicationjob core_duplicateapplicationjob_duplicated_application_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_duplicateapplicationjob
    ADD CONSTRAINT core_duplicateapplicationjob_duplicated_application_id_key UNIQUE (duplicated_application_id);


--
-- Name: core_duplicateapplicationjob core_duplicateapplicationjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_duplicateapplicationjob
    ADD CONSTRAINT core_duplicateapplicationjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: core_exportapplicationsjob core_exportapplicationsjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_exportapplicationsjob
    ADD CONSTRAINT core_exportapplicationsjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: core_workspace core_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workspace
    ADD CONSTRAINT core_group_pkey PRIMARY KEY (id);


--
-- Name: core_workspaceinvitation core_groupinvitation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workspaceinvitation
    ADD CONSTRAINT core_groupinvitation_pkey PRIMARY KEY (id);


--
-- Name: core_workspaceuser core_groupuser_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workspaceuser
    ADD CONSTRAINT core_groupuser_pkey PRIMARY KEY (id);


--
-- Name: core_workspaceuser core_groupuser_user_id_group_id_c249a931_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workspaceuser
    ADD CONSTRAINT core_groupuser_user_id_group_id_c249a931_uniq UNIQUE (user_id, workspace_id);


--
-- Name: core_importapplicationsjob core_importapplicationsjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_importapplicationsjob
    ADD CONSTRAINT core_importapplicationsjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: core_importexportresource core_importexportresource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_importexportresource
    ADD CONSTRAINT core_importexportresource_pkey PRIMARY KEY (id);


--
-- Name: core_importexporttrustedsource core_importexporttrustedsource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_importexporttrustedsource
    ADD CONSTRAINT core_importexporttrustedsource_pkey PRIMARY KEY (id);


--
-- Name: core_installtemplatejob core_installtemplatejob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_installtemplatejob
    ADD CONSTRAINT core_installtemplatejob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: core_integration core_integration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_integration
    ADD CONSTRAINT core_integration_pkey PRIMARY KEY (id);


--
-- Name: core_job core_job_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_job
    ADD CONSTRAINT core_job_pkey PRIMARY KEY (id);


--
-- Name: core_mcpendpoint core_mcpendpoint_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_mcpendpoint
    ADD CONSTRAINT core_mcpendpoint_key_key UNIQUE (key);


--
-- Name: core_mcpendpoint core_mcpendpoint_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_mcpendpoint
    ADD CONSTRAINT core_mcpendpoint_pkey PRIMARY KEY (id);


--
-- Name: core_notification core_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_notification
    ADD CONSTRAINT core_notification_pkey PRIMARY KEY (id);


--
-- Name: core_notificationrecipient core_notificationrecipie_notification_id_recipien_7f7941a1_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_notificationrecipient
    ADD CONSTRAINT core_notificationrecipie_notification_id_recipien_7f7941a1_uniq UNIQUE (notification_id, recipient_id);


--
-- Name: core_notificationrecipient core_notificationrecipient_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_notificationrecipient
    ADD CONSTRAINT core_notificationrecipient_pkey PRIMARY KEY (id);


--
-- Name: core_operation core_operation_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_operation
    ADD CONSTRAINT core_operation_name_key UNIQUE (name);


--
-- Name: core_operation core_operation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_operation
    ADD CONSTRAINT core_operation_pkey PRIMARY KEY (id);


--
-- Name: core_passwordauthprovidermodel core_passwordauthprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_passwordauthprovidermodel
    ADD CONSTRAINT core_passwordauthprovidermodel_pkey PRIMARY KEY (authprovidermodel_ptr_id);


--
-- Name: core_restoresnapshotjob core_restoresnapshotjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_restoresnapshotjob
    ADD CONSTRAINT core_restoresnapshotjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: core_schemaoperation core_schemaoperation_content_type_id_operation_7130e624_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_schemaoperation
    ADD CONSTRAINT core_schemaoperation_content_type_id_operation_7130e624_uniq UNIQUE (content_type_id, operation);


--
-- Name: core_schemaoperation core_schemaoperation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_schemaoperation
    ADD CONSTRAINT core_schemaoperation_pkey PRIMARY KEY (id);


--
-- Name: core_service core_service_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_service
    ADD CONSTRAINT core_service_pkey PRIMARY KEY (id);


--
-- Name: core_settings core_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_settings
    ADD CONSTRAINT core_settings_pkey PRIMARY KEY (id);


--
-- Name: core_snapshot core_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_snapshot
    ADD CONSTRAINT core_snapshot_pkey PRIMARY KEY (id);


--
-- Name: core_template_categories core_template_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_template_categories
    ADD CONSTRAINT core_template_categories_pkey PRIMARY KEY (id);


--
-- Name: core_template_categories core_template_categories_template_id_templatecate_6b419aef_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_template_categories
    ADD CONSTRAINT core_template_categories_template_id_templatecate_6b419aef_uniq UNIQUE (template_id, templatecategory_id);


--
-- Name: core_template core_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_template
    ADD CONSTRAINT core_template_pkey PRIMARY KEY (id);


--
-- Name: core_templatecategory core_templatecategory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_templatecategory
    ADD CONSTRAINT core_templatecategory_pkey PRIMARY KEY (id);


--
-- Name: core_totpauthprovidermodel core_totpauthprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_totpauthprovidermodel
    ADD CONSTRAINT core_totpauthprovidermodel_pkey PRIMARY KEY (twofactorauthprovidermodel_ptr_id);


--
-- Name: core_totpusedcode core_totpusedcode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_totpusedcode
    ADD CONSTRAINT core_totpusedcode_pkey PRIMARY KEY (id);


--
-- Name: core_trashentry core_trashentry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_trashentry
    ADD CONSTRAINT core_trashentry_pkey PRIMARY KEY (id);


--
-- Name: core_twofactorauthprovidermodel core_twofactorauthprovidermodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_twofactorauthprovidermodel
    ADD CONSTRAINT core_twofactorauthprovidermodel_pkey PRIMARY KEY (id);


--
-- Name: core_twofactorauthprovidermodel core_twofactorauthprovidermodel_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_twofactorauthprovidermodel
    ADD CONSTRAINT core_twofactorauthprovidermodel_user_id_key UNIQUE (user_id);


--
-- Name: core_twofactorauthrecoverycode core_twofactorauthrecoverycode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_twofactorauthrecoverycode
    ADD CONSTRAINT core_twofactorauthrecoverycode_pkey PRIMARY KEY (id);


--
-- Name: core_userfile core_userfile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_userfile
    ADD CONSTRAINT core_userfile_pkey PRIMARY KEY (id);


--
-- Name: core_userlogentry core_userlogentry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_userlogentry
    ADD CONSTRAINT core_userlogentry_pkey PRIMARY KEY (id);


--
-- Name: core_userprofile core_userprofile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_userprofile
    ADD CONSTRAINT core_userprofile_pkey PRIMARY KEY (id);


--
-- Name: core_userprofile core_userprofile_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_userprofile
    ADD CONSTRAINT core_userprofile_user_id_key UNIQUE (user_id);


--
-- Name: core_usersource core_usersource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_usersource
    ADD CONSTRAINT core_usersource_pkey PRIMARY KEY (id);


--
-- Name: core_usersource core_usersource_uid_0ba94fb4_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_usersource
    ADD CONSTRAINT core_usersource_uid_0ba94fb4_uniq UNIQUE (uid);


--
-- Name: core_workspaceinvitation core_workspaceinvitation_workspace_id_email_4e76afe3_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workspaceinvitation
    ADD CONSTRAINT core_workspaceinvitation_workspace_id_email_4e76afe3_uniq UNIQUE (workspace_id, email);


--
-- Name: dashboard_dashboard dashboard_dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_dashboard
    ADD CONSTRAINT dashboard_dashboard_pkey PRIMARY KEY (application_ptr_id);


--
-- Name: dashboard_dashboarddatasource dashboard_dashboarddatasource_dashboard_id_name_e1b51af6_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_dashboarddatasource
    ADD CONSTRAINT dashboard_dashboarddatasource_dashboard_id_name_e1b51af6_uniq UNIQUE (dashboard_id, name);


--
-- Name: dashboard_dashboarddatasource dashboard_dashboarddatasource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_dashboarddatasource
    ADD CONSTRAINT dashboard_dashboarddatasource_pkey PRIMARY KEY (id);


--
-- Name: dashboard_dashboarddatasource dashboard_dashboarddatasource_service_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_dashboarddatasource
    ADD CONSTRAINT dashboard_dashboarddatasource_service_id_key UNIQUE (service_id);


--
-- Name: dashboard_summarywidget dashboard_summarywidget_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_summarywidget
    ADD CONSTRAINT dashboard_summarywidget_pkey PRIMARY KEY (widget_ptr_id);


--
-- Name: dashboard_widget dashboard_widget_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_widget
    ADD CONSTRAINT dashboard_widget_pkey PRIMARY KEY (id);


--
-- Name: database_airtableimportjob database_airtableimportjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_airtableimportjob
    ADD CONSTRAINT database_airtableimportjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: database_autonumberfield database_autonumberfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_autonumberfield
    ADD CONSTRAINT database_autonumberfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_booleanfield database_booleanfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_booleanfield
    ADD CONSTRAINT database_booleanfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_calendarview database_calendarview_ical_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_calendarview
    ADD CONSTRAINT database_calendarview_ical_slug_key UNIQUE (ical_slug);


--
-- Name: database_calendarview database_calendarview_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_calendarview
    ADD CONSTRAINT database_calendarview_pkey PRIMARY KEY (view_ptr_id);


--
-- Name: database_calendarviewfieldoptions database_calendarviewfie_calendar_view_id_field_i_fb52c643_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_calendarviewfieldoptions
    ADD CONSTRAINT database_calendarviewfie_calendar_view_id_field_i_fb52c643_uniq UNIQUE (calendar_view_id, field_id);


--
-- Name: database_calendarviewfieldoptions database_calendarviewfieldoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_calendarviewfieldoptions
    ADD CONSTRAINT database_calendarviewfieldoptions_pkey PRIMARY KEY (id);


--
-- Name: database_countfield database_countfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_countfield
    ADD CONSTRAINT database_countfield_pkey PRIMARY KEY (formulafield_ptr_id);


--
-- Name: database_createdbyfield database_createdbyfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_createdbyfield
    ADD CONSTRAINT database_createdbyfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_createdonfield database_createdonfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_createdonfield
    ADD CONSTRAINT database_createdonfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_database database_database_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_database
    ADD CONSTRAINT database_database_pkey PRIMARY KEY (application_ptr_id);


--
-- Name: database_datasync database_datasync_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_datasync
    ADD CONSTRAINT database_datasync_pkey PRIMARY KEY (id);


--
-- Name: database_datasync database_datasync_table_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_datasync
    ADD CONSTRAINT database_datasync_table_id_key UNIQUE (table_id);


--
-- Name: database_datasyncsyncedproperty database_datasyncsyncedproperty_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_datasyncsyncedproperty
    ADD CONSTRAINT database_datasyncsyncedproperty_pkey PRIMARY KEY (id);


--
-- Name: database_datefield database_datefield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_datefield
    ADD CONSTRAINT database_datefield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_duplicatefieldjob database_duplicatefieldjob_duplicated_field_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_duplicatefieldjob
    ADD CONSTRAINT database_duplicatefieldjob_duplicated_field_id_key UNIQUE (duplicated_field_id);


--
-- Name: database_duplicatefieldjob database_duplicatefieldjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_duplicatefieldjob
    ADD CONSTRAINT database_duplicatefieldjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: database_duplicatetablejob database_duplicatetablejob_duplicated_table_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_duplicatetablejob
    ADD CONSTRAINT database_duplicatetablejob_duplicated_table_id_key UNIQUE (duplicated_table_id);


--
-- Name: database_duplicatetablejob database_duplicatetablejob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_duplicatetablejob
    ADD CONSTRAINT database_duplicatetablejob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: database_durationfield database_durationfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_durationfield
    ADD CONSTRAINT database_durationfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_emailfield database_emailfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_emailfield
    ADD CONSTRAINT database_emailfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_exportjob database_exportjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_exportjob
    ADD CONSTRAINT database_exportjob_pkey PRIMARY KEY (id);


--
-- Name: database_field database_field_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_field
    ADD CONSTRAINT database_field_pkey PRIMARY KEY (id);


--
-- Name: database_fieldconstraint database_fieldconstraint_field_id_type_name_a47e3825_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fieldconstraint
    ADD CONSTRAINT database_fieldconstraint_field_id_type_name_a47e3825_uniq UNIQUE (field_id, type_name);


--
-- Name: database_fieldconstraint database_fieldconstraint_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fieldconstraint
    ADD CONSTRAINT database_fieldconstraint_pkey PRIMARY KEY (id);


--
-- Name: database_fielddependency database_fielddependency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fielddependency
    ADD CONSTRAINT database_fielddependency_pkey PRIMARY KEY (id);


--
-- Name: database_fieldrule database_fieldrule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fieldrule
    ADD CONSTRAINT database_fieldrule_pkey PRIMARY KEY (id);


--
-- Name: database_filefield database_filefield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_filefield
    ADD CONSTRAINT database_filefield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_fileimportjob database_fileimportjob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fileimportjob
    ADD CONSTRAINT database_fileimportjob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: database_formulafield database_formulafield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formulafield
    ADD CONSTRAINT database_formulafield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_formview database_formview_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formview
    ADD CONSTRAINT database_formview_pkey PRIMARY KEY (view_ptr_id);


--
-- Name: database_formview_users_to_notify_on_submit database_formview_users__formview_id_user_id_328d4956_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formview_users_to_notify_on_submit
    ADD CONSTRAINT database_formview_users__formview_id_user_id_328d4956_uniq UNIQUE (formview_id, user_id);


--
-- Name: database_formview_users_to_notify_on_submit database_formview_users_to_notify_on_submit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formview_users_to_notify_on_submit
    ADD CONSTRAINT database_formview_users_to_notify_on_submit_pkey PRIMARY KEY (id);


--
-- Name: database_formvieweditrowfield database_formvieweditrowfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formvieweditrowfield
    ADD CONSTRAINT database_formvieweditrowfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_formviewfieldoptions database_formviewfieldop_form_view_id_field_id_7e1d3308_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptions
    ADD CONSTRAINT database_formviewfieldop_form_view_id_field_id_7e1d3308_uniq UNIQUE (form_view_id, field_id);


--
-- Name: database_formviewfieldoptions database_formviewfieldoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptions
    ADD CONSTRAINT database_formviewfieldoptions_pkey PRIMARY KEY (id);


--
-- Name: database_formviewfieldoptionsallowedselectoptions database_formviewfieldoptionsallowedselectoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptionsallowedselectoptions
    ADD CONSTRAINT database_formviewfieldoptionsallowedselectoptions_pkey PRIMARY KEY (id);


--
-- Name: database_formviewfieldoptionscondition database_formviewfieldoptionscondition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptionscondition
    ADD CONSTRAINT database_formviewfieldoptionscondition_pkey PRIMARY KEY (id);


--
-- Name: database_formviewfieldoptionsconditiongroup database_formviewfieldoptionsconditiongroup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptionsconditiongroup
    ADD CONSTRAINT database_formviewfieldoptionsconditiongroup_pkey PRIMARY KEY (id);


--
-- Name: database_galleryview database_galleryview_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_galleryview
    ADD CONSTRAINT database_galleryview_pkey PRIMARY KEY (view_ptr_id);


--
-- Name: database_galleryviewfieldoptions database_galleryviewfiel_gallery_view_id_field_id_7b7a24fc_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_galleryviewfieldoptions
    ADD CONSTRAINT database_galleryviewfiel_gallery_view_id_field_id_7b7a24fc_uniq UNIQUE (gallery_view_id, field_id);


--
-- Name: database_galleryviewfieldoptions database_galleryviewfieldoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_galleryviewfieldoptions
    ADD CONSTRAINT database_galleryviewfieldoptions_pkey PRIMARY KEY (id);


--
-- Name: database_gridview database_gridview_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_gridview
    ADD CONSTRAINT database_gridview_pkey PRIMARY KEY (view_ptr_id);


--
-- Name: database_gridviewfieldoptions database_gridviewfieldop_grid_view_id_field_id_f7df3f39_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_gridviewfieldoptions
    ADD CONSTRAINT database_gridviewfieldop_grid_view_id_field_id_f7df3f39_uniq UNIQUE (grid_view_id, field_id);


--
-- Name: database_gridviewfieldoptions database_gridviewfieldoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_gridviewfieldoptions
    ADD CONSTRAINT database_gridviewfieldoptions_pkey PRIMARY KEY (id);


--
-- Name: database_icalcalendardatasync database_icalcalendardatasync_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_icalcalendardatasync
    ADD CONSTRAINT database_icalcalendardatasync_pkey PRIMARY KEY (datasync_ptr_id);


--
-- Name: database_kanbanview database_kanbanview_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_kanbanview
    ADD CONSTRAINT database_kanbanview_pkey PRIMARY KEY (view_ptr_id);


--
-- Name: database_kanbanviewfieldoptions database_kanbanviewfield_kanban_view_id_field_id_73dff40d_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_kanbanviewfieldoptions
    ADD CONSTRAINT database_kanbanviewfield_kanban_view_id_field_id_73dff40d_uniq UNIQUE (kanban_view_id, field_id);


--
-- Name: database_kanbanviewfieldoptions database_kanbanviewfieldoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_kanbanviewfieldoptions
    ADD CONSTRAINT database_kanbanviewfieldoptions_pkey PRIMARY KEY (id);


--
-- Name: database_lastmodifiedbyfield database_lastmodifiedbyfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_lastmodifiedbyfield
    ADD CONSTRAINT database_lastmodifiedbyfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_lastmodifiedfield database_lastmodifiedfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_lastmodifiedfield
    ADD CONSTRAINT database_lastmodifiedfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_linkrowfield database_linkrowfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_linkrowfield
    ADD CONSTRAINT database_linkrowfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_longtextfield database_longtextfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_longtextfield
    ADD CONSTRAINT database_longtextfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_lookupfield database_lookupfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_lookupfield
    ADD CONSTRAINT database_lookupfield_pkey PRIMARY KEY (formulafield_ptr_id);


--
-- Name: database_multiplecollaboratorsfield database_multiplecollaboratorsfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_multiplecollaboratorsfield
    ADD CONSTRAINT database_multiplecollaboratorsfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_multipleselect_46 database_multipleselect_46_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_multipleselect_46
    ADD CONSTRAINT database_multipleselect_46_pkey PRIMARY KEY (id);


--
-- Name: database_multipleselect_46 database_multipleselect__table7model_id_multiples_52dffb5a_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_multipleselect_46
    ADD CONSTRAINT database_multipleselect__table7model_id_multiples_52dffb5a_uniq UNIQUE (table7model_id, multipleselectfield46selectoption_id);


--
-- Name: database_multipleselectfield database_multipleselectfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_multipleselectfield
    ADD CONSTRAINT database_multipleselectfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_numberfield database_numberfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_numberfield
    ADD CONSTRAINT database_numberfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_passwordfield database_passwordfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_passwordfield
    ADD CONSTRAINT database_passwordfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_pendingsearchvalueupdate database_pendingsearchvalueupdate_field_id_row_id_8cfa0e82_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_pendingsearchvalueupdate
    ADD CONSTRAINT database_pendingsearchvalueupdate_field_id_row_id_8cfa0e82_uniq UNIQUE (field_id, row_id);


--
-- Name: database_pendingsearchvalueupdate database_pendingsearchvalueupdate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_pendingsearchvalueupdate
    ADD CONSTRAINT database_pendingsearchvalueupdate_pkey PRIMARY KEY (id);


--
-- Name: database_phonenumberfield database_phonenumberfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_phonenumberfield
    ADD CONSTRAINT database_phonenumberfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_postgresqldatasync database_postgresqldatasync_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_postgresqldatasync
    ADD CONSTRAINT database_postgresqldatasync_pkey PRIMARY KEY (datasync_ptr_id);


--
-- Name: database_ratingfield database_ratingfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_ratingfield
    ADD CONSTRAINT database_ratingfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_relation_1 database_relation_1_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_1
    ADD CONSTRAINT database_relation_1_pkey PRIMARY KEY (id);


--
-- Name: database_relation_1 database_relation_1_table1model_id_table4model_id_6b21fc2d_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_1
    ADD CONSTRAINT database_relation_1_table1model_id_table4model_id_6b21fc2d_uniq UNIQUE (table1model_id, table4model_id);


--
-- Name: database_relation_2 database_relation_2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_2
    ADD CONSTRAINT database_relation_2_pkey PRIMARY KEY (id);


--
-- Name: database_relation_2 database_relation_2_table1model_id_table2model_id_8996d7e0_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_2
    ADD CONSTRAINT database_relation_2_table1model_id_table2model_id_8996d7e0_uniq UNIQUE (table1model_id, table2model_id);


--
-- Name: database_relation_3 database_relation_3_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_3
    ADD CONSTRAINT database_relation_3_pkey PRIMARY KEY (id);


--
-- Name: database_relation_3 database_relation_3_table1model_id_table6model_id_1872ae56_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_3
    ADD CONSTRAINT database_relation_3_table1model_id_table6model_id_1872ae56_uniq UNIQUE (table1model_id, table6model_id);


--
-- Name: database_relation_4 database_relation_4_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_4
    ADD CONSTRAINT database_relation_4_pkey PRIMARY KEY (id);


--
-- Name: database_relation_4 database_relation_4_table1model_id_table5model_id_3bc8db90_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_4
    ADD CONSTRAINT database_relation_4_table1model_id_table5model_id_3bc8db90_uniq UNIQUE (table1model_id, table5model_id);


--
-- Name: database_relation_5 database_relation_5_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_5
    ADD CONSTRAINT database_relation_5_pkey PRIMARY KEY (id);


--
-- Name: database_relation_5 database_relation_5_table2model_id_table3model_id_48d81745_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_5
    ADD CONSTRAINT database_relation_5_table2model_id_table3model_id_48d81745_uniq UNIQUE (table2model_id, table3model_id);


--
-- Name: database_relation_6 database_relation_6_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_6
    ADD CONSTRAINT database_relation_6_pkey PRIMARY KEY (id);


--
-- Name: database_relation_6 database_relation_6_table6model_id_table7model_id_d524bfab_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_6
    ADD CONSTRAINT database_relation_6_table6model_id_table7model_id_d524bfab_uniq UNIQUE (table6model_id, table7model_id);


--
-- Name: database_relation_7 database_relation_7_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_7
    ADD CONSTRAINT database_relation_7_pkey PRIMARY KEY (id);


--
-- Name: database_relation_7 database_relation_7_table8model_id_table9model_id_51bd7200_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_relation_7
    ADD CONSTRAINT database_relation_7_table8model_id_table9model_id_51bd7200_uniq UNIQUE (table8model_id, table9model_id);


--
-- Name: database_richtextfieldmention database_richtextfieldme_table_id_row_id_field_id_4a3b0d87_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_richtextfieldmention
    ADD CONSTRAINT database_richtextfieldme_table_id_row_id_field_id_4a3b0d87_uniq UNIQUE (table_id, row_id, field_id, user_id);


--
-- Name: database_richtextfieldmention database_richtextfieldmention_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_richtextfieldmention
    ADD CONSTRAINT database_richtextfieldmention_pkey PRIMARY KEY (id);


--
-- Name: database_rollupfield database_rollupfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rollupfield
    ADD CONSTRAINT database_rollupfield_pkey PRIMARY KEY (formulafield_ptr_id);


--
-- Name: database_rowcomment_mentions database_rowcomment_ment_rowcomment_id_user_id_8a5b68b5_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rowcomment_mentions
    ADD CONSTRAINT database_rowcomment_ment_rowcomment_id_user_id_8a5b68b5_uniq UNIQUE (rowcomment_id, user_id);


--
-- Name: database_rowcomment_mentions database_rowcomment_mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rowcomment_mentions
    ADD CONSTRAINT database_rowcomment_mentions_pkey PRIMARY KEY (id);


--
-- Name: database_rowcomment database_rowcomment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rowcomment
    ADD CONSTRAINT database_rowcomment_pkey PRIMARY KEY (id);


--
-- Name: database_rowhistory database_rowhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rowhistory
    ADD CONSTRAINT database_rowhistory_pkey PRIMARY KEY (id);


--
-- Name: database_selectoption database_selectoption_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_selectoption
    ADD CONSTRAINT database_selectoption_pkey PRIMARY KEY (id);


--
-- Name: database_singleselectfield database_singleselectfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_singleselectfield
    ADD CONSTRAINT database_singleselectfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_syncdatasynctablejob database_syncdatasynctablejob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_syncdatasynctablejob
    ADD CONSTRAINT database_syncdatasynctablejob_pkey PRIMARY KEY (job_ptr_id);


--
-- Name: database_table_1 database_table_1_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_table_1
    ADD CONSTRAINT database_table_1_pkey PRIMARY KEY (id);


--
-- Name: database_table_2 database_table_2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_table_2
    ADD CONSTRAINT database_table_2_pkey PRIMARY KEY (id);


--
-- Name: database_table_3 database_table_3_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_table_3
    ADD CONSTRAINT database_table_3_pkey PRIMARY KEY (id);


--
-- Name: database_table_4 database_table_4_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_table_4
    ADD CONSTRAINT database_table_4_pkey PRIMARY KEY (id);


--
-- Name: database_table_5 database_table_5_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_table_5
    ADD CONSTRAINT database_table_5_pkey PRIMARY KEY (id);


--
-- Name: database_table_6 database_table_6_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_table_6
    ADD CONSTRAINT database_table_6_pkey PRIMARY KEY (id);


--
-- Name: database_table_7 database_table_7_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_table_7
    ADD CONSTRAINT database_table_7_pkey PRIMARY KEY (id);


--
-- Name: database_table_8 database_table_8_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_table_8
    ADD CONSTRAINT database_table_8_pkey PRIMARY KEY (id);


--
-- Name: database_table_9 database_table_9_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_table_9
    ADD CONSTRAINT database_table_9_pkey PRIMARY KEY (id);


--
-- Name: database_table database_table_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_table
    ADD CONSTRAINT database_table_pkey PRIMARY KEY (id);


--
-- Name: database_tableusage database_tableusage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tableusage
    ADD CONSTRAINT database_tableusage_pkey PRIMARY KEY (id);


--
-- Name: database_tableusage database_tableusage_table_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tableusage
    ADD CONSTRAINT database_tableusage_table_id_key UNIQUE (table_id);


--
-- Name: database_tableusageupdate database_tableusageupdate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tableusageupdate
    ADD CONSTRAINT database_tableusageupdate_pkey PRIMARY KEY (id);


--
-- Name: database_tablewebhook database_tablewebhook_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhook
    ADD CONSTRAINT database_tablewebhook_pkey PRIMARY KEY (id);


--
-- Name: database_tablewebhookcall database_tablewebhookcal_event_id_batch_id_webhoo_ca4e8359_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookcall
    ADD CONSTRAINT database_tablewebhookcal_event_id_batch_id_webhoo_ca4e8359_uniq UNIQUE (event_id, batch_id, webhook_id, event_type);


--
-- Name: database_tablewebhookcall database_tablewebhookcall_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookcall
    ADD CONSTRAINT database_tablewebhookcall_pkey PRIMARY KEY (id);


--
-- Name: database_tablewebhookevent_fields database_tablewebhookeve_tablewebhookevent_id_fie_5e1ff491_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookevent_fields
    ADD CONSTRAINT database_tablewebhookeve_tablewebhookevent_id_fie_5e1ff491_uniq UNIQUE (tablewebhookevent_id, field_id);


--
-- Name: database_tablewebhookevent_views database_tablewebhookeve_tablewebhookevent_id_vie_060064e3_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookevent_views
    ADD CONSTRAINT database_tablewebhookeve_tablewebhookevent_id_vie_060064e3_uniq UNIQUE (tablewebhookevent_id, view_id);


--
-- Name: database_tablewebhookevent_fields database_tablewebhookevent_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookevent_fields
    ADD CONSTRAINT database_tablewebhookevent_fields_pkey PRIMARY KEY (id);


--
-- Name: database_tablewebhookevent database_tablewebhookevent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookevent
    ADD CONSTRAINT database_tablewebhookevent_pkey PRIMARY KEY (id);


--
-- Name: database_tablewebhookevent_views database_tablewebhookevent_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookevent_views
    ADD CONSTRAINT database_tablewebhookevent_views_pkey PRIMARY KEY (id);


--
-- Name: database_tablewebhookheader database_tablewebhookheader_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookheader
    ADD CONSTRAINT database_tablewebhookheader_pkey PRIMARY KEY (id);


--
-- Name: database_textfield database_textfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_textfield
    ADD CONSTRAINT database_textfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_timelineview database_timelineview_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_timelineview
    ADD CONSTRAINT database_timelineview_pkey PRIMARY KEY (view_ptr_id);


--
-- Name: database_timelineviewfieldoptions database_timelineviewfie_timeline_view_id_field_i_647900c1_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_timelineviewfieldoptions
    ADD CONSTRAINT database_timelineviewfie_timeline_view_id_field_i_647900c1_uniq UNIQUE (timeline_view_id, field_id);


--
-- Name: database_timelineviewfieldoptions database_timelineviewfieldoptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_timelineviewfieldoptions
    ADD CONSTRAINT database_timelineviewfieldoptions_pkey PRIMARY KEY (id);


--
-- Name: database_token database_token_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_token
    ADD CONSTRAINT database_token_key_key UNIQUE (key);


--
-- Name: database_token database_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_token
    ADD CONSTRAINT database_token_pkey PRIMARY KEY (id);


--
-- Name: database_tokenpermission database_tokenpermission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tokenpermission
    ADD CONSTRAINT database_tokenpermission_pkey PRIMARY KEY (id);


--
-- Name: database_trashedrows database_trashedrows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_trashedrows
    ADD CONSTRAINT database_trashedrows_pkey PRIMARY KEY (id);


--
-- Name: database_urlfield database_urlfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_urlfield
    ADD CONSTRAINT database_urlfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_uuidfield database_uuidfield_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_uuidfield
    ADD CONSTRAINT database_uuidfield_pkey PRIMARY KEY (field_ptr_id);


--
-- Name: database_view database_view_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_view
    ADD CONSTRAINT database_view_pkey PRIMARY KEY (id);


--
-- Name: database_view database_view_slug_temp_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_view
    ADD CONSTRAINT database_view_slug_temp_key UNIQUE (slug);


--
-- Name: database_viewdecoration database_viewdecoration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewdecoration
    ADD CONSTRAINT database_viewdecoration_pkey PRIMARY KEY (id);


--
-- Name: database_viewdefaultvalue database_viewdefaultvalue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewdefaultvalue
    ADD CONSTRAINT database_viewdefaultvalue_pkey PRIMARY KEY (id);


--
-- Name: database_viewfilter database_viewfilter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewfilter
    ADD CONSTRAINT database_viewfilter_pkey PRIMARY KEY (id);


--
-- Name: database_viewfiltergroup database_viewfiltergroup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewfiltergroup
    ADD CONSTRAINT database_viewfiltergroup_pkey PRIMARY KEY (id);


--
-- Name: database_viewgroupby database_viewgroupby_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewgroupby
    ADD CONSTRAINT database_viewgroupby_pkey PRIMARY KEY (id);


--
-- Name: database_viewrows database_viewrows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewrows
    ADD CONSTRAINT database_viewrows_pkey PRIMARY KEY (id);


--
-- Name: database_viewrows database_viewrows_view_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewrows
    ADD CONSTRAINT database_viewrows_view_id_key UNIQUE (view_id);


--
-- Name: database_viewsort database_viewsort_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewsort
    ADD CONSTRAINT database_viewsort_pkey PRIMARY KEY (id);


--
-- Name: database_viewsubscription database_viewsubscriptio_view_id_subscriber_conte_e1609fa1_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewsubscription
    ADD CONSTRAINT database_viewsubscriptio_view_id_subscriber_conte_e1609fa1_uniq UNIQUE (view_id, subscriber_content_type_id, subscriber_id);


--
-- Name: database_viewsubscription database_viewsubscription_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewsubscription
    ADD CONSTRAINT database_viewsubscription_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: health_check_db_testmodel health_check_db_testmodel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.health_check_db_testmodel
    ADD CONSTRAINT health_check_db_testmodel_pkey PRIMARY KEY (id);


--
-- Name: integrations_aiagentservice integrations_aiagentservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_aiagentservice
    ADD CONSTRAINT integrations_aiagentservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_aiintegration integrations_aiintegration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_aiintegration
    ADD CONSTRAINT integrations_aiintegration_pkey PRIMARY KEY (integration_ptr_id);


--
-- Name: integrations_corecsvfilereaderservice integrations_corecsvfilereaderservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corecsvfilereaderservice
    ADD CONSTRAINT integrations_corecsvfilereaderservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_corehttprequestservice integrations_corehttprequestservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corehttprequestservice
    ADD CONSTRAINT integrations_corehttprequestservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_corehttptriggerservice integrations_corehttptriggerservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corehttptriggerservice
    ADD CONSTRAINT integrations_corehttptriggerservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_coreiteratorservice integrations_coreiteratorservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_coreiteratorservice
    ADD CONSTRAINT integrations_coreiteratorservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_coremanualtriggerservice integrations_coremanualtriggerservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_coremanualtriggerservice
    ADD CONSTRAINT integrations_coremanualtriggerservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_coreperiodicservice integrations_coreperiodicservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_coreperiodicservice
    ADD CONSTRAINT integrations_coreperiodicservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_corerouterservice integrations_corerouterservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corerouterservice
    ADD CONSTRAINT integrations_corerouterservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_corerouterserviceedge integrations_corerouterserviceedge_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corerouterserviceedge
    ADD CONSTRAINT integrations_corerouterserviceedge_pkey PRIMARY KEY (id);


--
-- Name: integrations_coresmtpemailservice integrations_coresmtpemailservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_coresmtpemailservice
    ADD CONSTRAINT integrations_coresmtpemailservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_corestartworkflowservice integrations_corestartworkflowservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corestartworkflowservice
    ADD CONSTRAINT integrations_corestartworkflowservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_httpformdata integrations_httpformdata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_httpformdata
    ADD CONSTRAINT integrations_httpformdata_pkey PRIMARY KEY (id);


--
-- Name: integrations_httpheader integrations_httpheader_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_httpheader
    ADD CONSTRAINT integrations_httpheader_pkey PRIMARY KEY (id);


--
-- Name: integrations_httpqueryparam integrations_httpqueryparam_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_httpqueryparam
    ADD CONSTRAINT integrations_httpqueryparam_pkey PRIMARY KEY (id);


--
-- Name: integrations_localbaserowfieldsupdated_fields integrations_localbasero_localbaserowfieldsupdate_ac9b9718_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowfieldsupdated_fields
    ADD CONSTRAINT integrations_localbasero_localbaserowfieldsupdate_ac9b9718_uniq UNIQUE (localbaserowfieldsupdated_id, field_id);


--
-- Name: integrations_localbaserowaggregaterows integrations_localbaserowaggregaterows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowaggregaterows
    ADD CONSTRAINT integrations_localbaserowaggregaterows_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_localbaserowcreaterows integrations_localbaserowcreaterows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowcreaterows
    ADD CONSTRAINT integrations_localbaserowcreaterows_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_localbaserowdeleterow integrations_localbaserowdeleterow_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowdeleterow
    ADD CONSTRAINT integrations_localbaserowdeleterow_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_localbaserowfieldsupdated_fields integrations_localbaserowfieldsupdated_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowfieldsupdated_fields
    ADD CONSTRAINT integrations_localbaserowfieldsupdated_fields_pkey PRIMARY KEY (id);


--
-- Name: integrations_localbaserowfieldsupdated integrations_localbaserowfieldsupdated_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowfieldsupdated
    ADD CONSTRAINT integrations_localbaserowfieldsupdated_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_localbaserowgetrow integrations_localbaserowgetrow_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowgetrow
    ADD CONSTRAINT integrations_localbaserowgetrow_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_localbaserowintegration integrations_localbaserowintegration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowintegration
    ADD CONSTRAINT integrations_localbaserowintegration_pkey PRIMARY KEY (integration_ptr_id);


--
-- Name: integrations_localbaserowlistrows integrations_localbaserowlistrows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowlistrows
    ADD CONSTRAINT integrations_localbaserowlistrows_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_localbaserowrowscreated integrations_localbaserowrowcreated_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowrowscreated
    ADD CONSTRAINT integrations_localbaserowrowcreated_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_localbaserowrowsdeleted integrations_localbaserowrowsdeleted_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowrowsdeleted
    ADD CONSTRAINT integrations_localbaserowrowsdeleted_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_localbaserowrowsupdated integrations_localbaserowrowupdated_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowrowsupdated
    ADD CONSTRAINT integrations_localbaserowrowupdated_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_localbaserowtableservicefieldmapping integrations_localbaserowtableservicefieldmapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowtableservicefieldmapping
    ADD CONSTRAINT integrations_localbaserowtableservicefieldmapping_pkey PRIMARY KEY (id);


--
-- Name: integrations_localbaserowtableservicefilter integrations_localbaserowtableservicefilter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowtableservicefilter
    ADD CONSTRAINT integrations_localbaserowtableservicefilter_pkey PRIMARY KEY (id);


--
-- Name: integrations_localbaserowtableservicesort integrations_localbaserowtableservicesort_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowtableservicesort
    ADD CONSTRAINT integrations_localbaserowtableservicesort_pkey PRIMARY KEY (id);


--
-- Name: integrations_localbaserowupdaterows integrations_localbaserowupdaterows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowupdaterows
    ADD CONSTRAINT integrations_localbaserowupdaterows_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_localbaserowupsertrow integrations_localbaserowupsertrow_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowupsertrow
    ADD CONSTRAINT integrations_localbaserowupsertrow_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_slackbotintegration integrations_slackbotintegration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_slackbotintegration
    ADD CONSTRAINT integrations_slackbotintegration_pkey PRIMARY KEY (integration_ptr_id);


--
-- Name: integrations_slackwritemessageservice integrations_slackwritemessageservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_slackwritemessageservice
    ADD CONSTRAINT integrations_slackwritemessageservice_pkey PRIMARY KEY (service_ptr_id);


--
-- Name: integrations_smtpintegration integrations_smtpintegration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_smtpintegration
    ADD CONSTRAINT integrations_smtpintegration_pkey PRIMARY KEY (integration_ptr_id);


--
-- Name: baserow_premium_piechartseriesconfig pie_chart_unique_series; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_piechartseriesconfig
    ADD CONSTRAINT pie_chart_unique_series UNIQUE (series_id);


--
-- Name: baserow_enterprise_roleassignment subject_and_scope_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_roleassignment
    ADD CONSTRAINT subject_and_scope_uniqueness UNIQUE (scope_id, scope_type_id, subject_id, subject_type_id);


--
-- Name: baserow_enterprise_knowledgebasechunk unique_document_index_constraint; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_knowledgebasechunk
    ADD CONSTRAINT unique_document_index_constraint UNIQUE (source_document_id, index);


--
-- Name: baserow_premium_chartseriesconfig unique_series; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_chartseriesconfig
    ADD CONSTRAINT unique_series UNIQUE (series_id);


--
-- Name: database_viewdefaultvalue unique_view_field_default_value; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewdefaultvalue
    ADD CONSTRAINT unique_view_field_default_value UNIQUE (view_id, field_id);


--
-- Name: core_trashentry unique_with_parent_trash_item_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_trashentry
    ADD CONSTRAINT unique_with_parent_trash_item_id UNIQUE (trash_item_type, parent_trash_item_id, trash_item_id);


--
-- Name: ws_realtime_events ws_realtime_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ws_realtime_events
    ADD CONSTRAINT ws_realtime_events_pkey PRIMARY KEY (id);


--
-- Name: ai_field_updated_on_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ai_field_updated_on_idx ON public.baserow_premium_aifieldscheduledupdate USING btree (field_id, updated_on DESC);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_group_id_97559544; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_user_id_6a12ed8b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_permission_id_1fbb5f2c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_user_id_a95ead1b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);


--
-- Name: auth_user_username_6821ab7c_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);


--
-- Name: automation__workflo_fa3be6_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation__workflo_fa3be6_idx ON public.automation_automationnodehistory USING btree (workflow_history_id, node_id);


--
-- Name: automation_automation_published_from_id_d6b4fa07; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automation_published_from_id_d6b4fa07 ON public.automation_automation USING btree (published_from_id);


--
-- Name: automation_automationnode_content_type_id_fd0edfc5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationnode_content_type_id_fd0edfc5 ON public.automation_automationnode USING btree (content_type_id);


--
-- Name: automation_automationnode_trashed_9a711755; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationnode_trashed_9a711755 ON public.automation_automationnode USING btree (trashed);


--
-- Name: automation_automationnode_workflow_id_21b932ab; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationnode_workflow_id_21b932ab ON public.automation_automationnode USING btree (workflow_id);


--
-- Name: automation_automationnodehistory_node_id_8af8495d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationnodehistory_node_id_8af8495d ON public.automation_automationnodehistory USING btree (node_id);


--
-- Name: automation_automationnodehistory_workflow_history_id_238f30d1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationnodehistory_workflow_history_id_238f30d1 ON public.automation_automationnodehistory USING btree (workflow_history_id);


--
-- Name: automation_automationnoderesult_node_history_id_a456f542; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationnoderesult_node_history_id_a456f542 ON public.automation_automationnoderesult USING btree (node_history_id);


--
-- Name: automation_automationworkf_automationworkflow_id_fb1c0706; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationworkf_automationworkflow_id_fb1c0706 ON public.automation_automationworkflow_notification_recipients USING btree (automationworkflow_id);


--
-- Name: automation_automationworkf_original_workflow_id_edf62aa0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationworkf_original_workflow_id_edf62aa0 ON public.automation_automationworkflowhistory USING btree (original_workflow_id);


--
-- Name: automation_automationworkf_simulate_until_node_id_19b153cb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationworkf_simulate_until_node_id_19b153cb ON public.automation_automationworkflowhistory USING btree (simulate_until_node_id);


--
-- Name: automation_automationworkf_user_id_c8d41f0d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationworkf_user_id_c8d41f0d ON public.automation_automationworkflow_notification_recipients USING btree (user_id);


--
-- Name: automation_automationworkflow_automation_id_ba6f1dbe; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationworkflow_automation_id_ba6f1dbe ON public.automation_automationworkflow USING btree (automation_id);


--
-- Name: automation_automationworkflow_simulate_until_node_id_8cd80a3c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationworkflow_simulate_until_node_id_8cd80a3c ON public.automation_automationworkflow USING btree (simulate_until_node_id);


--
-- Name: automation_automationworkflow_trashed_e40f5c86; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationworkflow_trashed_e40f5c86 ON public.automation_automationworkflow USING btree (trashed);


--
-- Name: automation_automationworkflowhistory_workflow_id_7c83997b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_automationworkflowhistory_workflow_id_7c83997b ON public.automation_automationworkflowhistory USING btree (workflow_id);


--
-- Name: automation_duplicateautoma_original_automation_workfl_0df8d772; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_duplicateautoma_original_automation_workfl_0df8d772 ON public.automation_duplicateautomationworkflowjob USING btree (original_automation_workflow_id);


--
-- Name: automation_publishautomati_automation_workflow_id_75834efa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automation_publishautomati_automation_workflow_id_75834efa ON public.automation_publishautomationworkflowjob USING btree (automation_workflow_id);


--
-- Name: baserow_ent_action__8db5d6_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_ent_action__8db5d6_idx ON public.baserow_enterprise_auditlogentry USING btree (action_timestamp DESC, user_id, workspace_id, action_type);


--
-- Name: baserow_ent_chat_id_914682_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_ent_chat_id_914682_idx ON public.baserow_enterprise_assistantchatmessage USING btree (chat_id, created_on);


--
-- Name: baserow_ent_created_01fb9f_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_ent_created_01fb9f_idx ON public.baserow_enterprise_teamsubject USING btree (created_on DESC);


--
-- Name: baserow_ent_scan_id_694735_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_ent_scan_id_694735_idx ON public.baserow_enterprise_datascanresult USING btree (scan_id, first_identified_on);


--
-- Name: baserow_ent_uid_5e9e91_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_ent_uid_5e9e91_idx ON public.baserow_enterprise_role USING btree (uid);


--
-- Name: baserow_ent_user_id_6107b7_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_ent_user_id_6107b7_idx ON public.baserow_enterprise_assistantchat USING btree (user_id, workspace_id, updated_on DESC);


--
-- Name: baserow_enterprise_assistantchat_user_id_b443a0fa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_assistantchat_user_id_b443a0fa ON public.baserow_enterprise_assistantchat USING btree (user_id);


--
-- Name: baserow_enterprise_assistantchat_workspace_id_8783706d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_assistantchat_workspace_id_8783706d ON public.baserow_enterprise_assistantchat USING btree (workspace_id);


--
-- Name: baserow_enterprise_assistantchatmessage_chat_id_53c3c94c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_assistantchatmessage_chat_id_53c3c94c ON public.baserow_enterprise_assistantchatmessage USING btree (chat_id);


--
-- Name: baserow_enterprise_authformelement_user_source_id_9f624b86; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_authformelement_user_source_id_9f624b86 ON public.baserow_enterprise_authformelement USING btree (user_source_id);


--
-- Name: baserow_enterprise_buildercustomscript_builder_id_3d974bcf; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_buildercustomscript_builder_id_3d974bcf ON public.baserow_enterprise_buildercustomscript USING btree (builder_id);


--
-- Name: baserow_enterprise_chartwidget_data_source_id_be88e5fb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_chartwidget_data_source_id_be88e5fb ON public.baserow_premium_chartwidget USING btree (data_source_id);


--
-- Name: baserow_enterprise_corecodeserviceinjection_service_id_de9af8c4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_corecodeserviceinjection_service_id_de9af8c4 ON public.baserow_enterprise_corecodeserviceinjection USING btree (service_id);


--
-- Name: baserow_enterprise_corecodeworkflowaction_service_id_ae419f30; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_corecodeworkflowaction_service_id_ae419f30 ON public.baserow_enterprise_corecodeworkflowaction USING btree (service_id);


--
-- Name: baserow_enterprise_corexls_service_id_5e05fb3a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_corexls_service_id_5e05fb3a ON public.baserow_enterprise_corexlsfilereaderworkflowaction USING btree (service_id);


--
-- Name: baserow_enterprise_datascan_created_by_id_4248af70; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datascan_created_by_id_4248af70 ON public.baserow_enterprise_datascan USING btree (created_by_id);


--
-- Name: baserow_enterprise_datascan_source_field_id_65f8d90c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datascan_source_field_id_65f8d90c ON public.baserow_enterprise_datascan USING btree (source_field_id);


--
-- Name: baserow_enterprise_datascan_source_table_id_ec7b7e89; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datascan_source_table_id_ec7b7e89 ON public.baserow_enterprise_datascan USING btree (source_table_id);


--
-- Name: baserow_enterprise_datascan_workspaces_datascan_id_0e9975cb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datascan_workspaces_datascan_id_0e9975cb ON public.baserow_enterprise_datascan_workspaces USING btree (datascan_id);


--
-- Name: baserow_enterprise_datascan_workspaces_workspace_id_d0b3400b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datascan_workspaces_workspace_id_d0b3400b ON public.baserow_enterprise_datascan_workspaces USING btree (workspace_id);


--
-- Name: baserow_enterprise_datascanlistitem_scan_id_7308d9e9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datascanlistitem_scan_id_7308d9e9 ON public.baserow_enterprise_datascanlistitem USING btree (scan_id);


--
-- Name: baserow_enterprise_datascanresult_field_id_615d75b1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datascanresult_field_id_615d75b1 ON public.baserow_enterprise_datascanresult USING btree (field_id);


--
-- Name: baserow_enterprise_datascanresult_first_identified_on_77e8e11c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datascanresult_first_identified_on_77e8e11c ON public.baserow_enterprise_datascanresult USING btree (first_identified_on);


--
-- Name: baserow_enterprise_datascanresult_scan_id_570da9b4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datascanresult_scan_id_570da9b4 ON public.baserow_enterprise_datascanresult USING btree (scan_id);


--
-- Name: baserow_enterprise_datascanresult_table_id_700dd2d7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datascanresult_table_id_700dd2d7 ON public.baserow_enterprise_datascanresult USING btree (table_id);


--
-- Name: baserow_enterprise_datedep_dependency_linkrow_field_i_ba4a26d1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datedep_dependency_linkrow_field_i_ba4a26d1 ON public.baserow_enterprise_datedependency USING btree (dependency_linkrow_field_id);


--
-- Name: baserow_enterprise_datedependency_duration_field_id_b8dfe787; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datedependency_duration_field_id_b8dfe787 ON public.baserow_enterprise_datedependency USING btree (duration_field_id);


--
-- Name: baserow_enterprise_datedependency_end_date_field_id_ae9d3818; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datedependency_end_date_field_id_ae9d3818 ON public.baserow_enterprise_datedependency USING btree (end_date_field_id);


--
-- Name: baserow_enterprise_datedependency_start_date_field_id_1d2f95f8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_datedependency_start_date_field_id_1d2f95f8 ON public.baserow_enterprise_datedependency USING btree (start_date_field_id);


--
-- Name: baserow_enterprise_knowled_source_document_id_ac49085f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_knowled_source_document_id_ac49085f ON public.baserow_enterprise_knowledgebasechunk USING btree (source_document_id);


--
-- Name: baserow_enterprise_knowledgebasecategory_name_c62c8e75_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_knowledgebasecategory_name_c62c8e75_like ON public.baserow_enterprise_knowledgebasecategory USING btree (name varchar_pattern_ops);


--
-- Name: baserow_enterprise_knowledgebasecategory_parent_id_a2ab88f8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_knowledgebasecategory_parent_id_a2ab88f8 ON public.baserow_enterprise_knowledgebasecategory USING btree (parent_id);


--
-- Name: baserow_enterprise_knowledgebasedocument_category_id_66c5bd32; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_knowledgebasedocument_category_id_66c5bd32 ON public.baserow_enterprise_knowledgebasedocument USING btree (category_id);


--
-- Name: baserow_enterprise_knowledgebasedocument_slug_bd15c159_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_knowledgebasedocument_slug_bd15c159_like ON public.baserow_enterprise_knowledgebasedocument USING btree (slug varchar_pattern_ops);


--
-- Name: baserow_enterprise_localba_authorized_user_id_87a841d7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_authorized_user_id_87a841d7 ON public.baserow_enterprise_localbaserowtabledatasync USING btree (authorized_user_id);


--
-- Name: baserow_enterprise_localba_email_field_id_5de36c5d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_email_field_id_5de36c5d ON public.baserow_enterprise_localbaserowusersource USING btree (email_field_id);


--
-- Name: baserow_enterprise_localba_field_id_54b77d5d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_field_id_54b77d5d ON public.baserow_premium_localbaserowtableserviceaggregationgroupby USING btree (field_id);


--
-- Name: baserow_enterprise_localba_field_id_6a50ba21; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_field_id_6a50ba21 ON public.baserow_premium_localbaserowtableserviceaggregationseries USING btree (field_id);


--
-- Name: baserow_enterprise_localba_name_field_id_fdbe641d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_name_field_id_fdbe641d ON public.baserow_enterprise_localbaserowusersource USING btree (name_field_id);


--
-- Name: baserow_enterprise_localba_password_field_id_96187f0c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_password_field_id_96187f0c ON public.baserow_enterprise_localbaserowpasswordappauthprovider USING btree (password_field_id);


--
-- Name: baserow_enterprise_localba_role_field_id_b061084a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_role_field_id_b061084a ON public.baserow_enterprise_localbaserowusersource USING btree (role_field_id);


--
-- Name: baserow_enterprise_localba_service_id_66409e2e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_service_id_66409e2e ON public.baserow_premium_localbaserowtableserviceaggregationsortby USING btree (service_id);


--
-- Name: baserow_enterprise_localba_service_id_c51c6b4e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_service_id_c51c6b4e ON public.baserow_premium_localbaserowtableserviceaggregationgroupby USING btree (service_id);


--
-- Name: baserow_enterprise_localba_service_id_f57c444d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_service_id_f57c444d ON public.baserow_premium_localbaserowtableserviceaggregationseries USING btree (service_id);


--
-- Name: baserow_enterprise_localba_source_table_id_367c2e8a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_source_table_id_367c2e8a ON public.baserow_enterprise_localbaserowtabledatasync USING btree (source_table_id);


--
-- Name: baserow_enterprise_localba_table_id_5c3a683d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_table_id_5c3a683d ON public.baserow_premium_localbaserowgroupedaggregaterows USING btree (table_id);


--
-- Name: baserow_enterprise_localba_view_id_6fd8a457; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localba_view_id_6fd8a457 ON public.baserow_premium_localbaserowgroupedaggregaterows USING btree (view_id);


--
-- Name: baserow_enterprise_localbaserowusersource_table_id_809436f6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_localbaserowusersource_table_id_809436f6 ON public.baserow_enterprise_localbaserowusersource USING btree (table_id);


--
-- Name: baserow_enterprise_periodi_authorized_user_id_a23b524f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_periodi_authorized_user_id_a23b524f ON public.baserow_enterprise_periodicdatasyncinterval USING btree (authorized_user_id);


--
-- Name: baserow_enterprise_role_group_id_fbf05cf7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_role_group_id_fbf05cf7 ON public.baserow_enterprise_role USING btree (workspace_id);


--
-- Name: baserow_enterprise_role_operations_operation_id_58992b0b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_role_operations_operation_id_58992b0b ON public.baserow_enterprise_role_operations USING btree (operation_id);


--
-- Name: baserow_enterprise_role_operations_role_id_46a1ac7b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_role_operations_role_id_46a1ac7b ON public.baserow_enterprise_role_operations USING btree (role_id);


--
-- Name: baserow_enterprise_role_uid_d7bde91e_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_role_uid_d7bde91e_like ON public.baserow_enterprise_role USING btree (uid varchar_pattern_ops);


--
-- Name: baserow_enterprise_roleassignment_group_id_e0c755e6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_roleassignment_group_id_e0c755e6 ON public.baserow_enterprise_roleassignment USING btree (workspace_id);


--
-- Name: baserow_enterprise_roleassignment_role_id_d591b8d7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_roleassignment_role_id_d591b8d7 ON public.baserow_enterprise_roleassignment USING btree (role_id);


--
-- Name: baserow_enterprise_roleassignment_scope_type_id_6190ffc7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_roleassignment_scope_type_id_6190ffc7 ON public.baserow_enterprise_roleassignment USING btree (scope_type_id);


--
-- Name: baserow_enterprise_roleassignment_subject_type_id_70e4e12b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_roleassignment_subject_type_id_70e4e12b ON public.baserow_enterprise_roleassignment USING btree (subject_type_id);


--
-- Name: baserow_enterprise_team_group_id_61fae35c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_team_group_id_61fae35c ON public.baserow_enterprise_team USING btree (workspace_id);


--
-- Name: baserow_enterprise_team_trashed_2c724d04; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_team_trashed_2c724d04 ON public.baserow_enterprise_team USING btree (trashed);


--
-- Name: baserow_enterprise_teamsubject_subject_id_aa3b0d43; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_teamsubject_subject_id_aa3b0d43 ON public.baserow_enterprise_teamsubject USING btree (subject_id);


--
-- Name: baserow_enterprise_teamsubject_subject_type_id_9e21b018; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_teamsubject_subject_type_id_9e21b018 ON public.baserow_enterprise_teamsubject USING btree (subject_type_id);


--
-- Name: baserow_enterprise_teamsubject_team_id_c1a2a489; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_enterprise_teamsubject_team_id_c1a2a489 ON public.baserow_enterprise_teamsubject USING btree (team_id);


--
-- Name: baserow_premium_aifield_ai_auto_update_user_id_5f71a313; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_aifield_ai_auto_update_user_id_5f71a313 ON public.baserow_premium_aifield USING btree (ai_auto_update_user_id);


--
-- Name: baserow_premium_aifield_ai_file_field_id_a16778ea; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_aifield_ai_file_field_id_a16778ea ON public.baserow_premium_aifield USING btree (ai_file_field_id);


--
-- Name: baserow_premium_chartseriesconfig_series_id_6ab3cf46; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_chartseriesconfig_series_id_6ab3cf46 ON public.baserow_premium_chartseriesconfig USING btree (series_id);


--
-- Name: baserow_premium_chartseriesconfig_widget_id_502d850d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_chartseriesconfig_widget_id_502d850d ON public.baserow_premium_chartseriesconfig USING btree (widget_id);


--
-- Name: baserow_premium_generateaivaluesjob_field_id_15cc461f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_generateaivaluesjob_field_id_15cc461f ON public.baserow_premium_generateaivaluesjob USING btree (field_id);


--
-- Name: baserow_premium_licenseuser_license_id_a98fcec6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_licenseuser_license_id_a98fcec6 ON public.baserow_premium_licenseuser USING btree (license_id);


--
-- Name: baserow_premium_licenseuser_user_id_562f4a98; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_licenseuser_user_id_562f4a98 ON public.baserow_premium_licenseuser USING btree (user_id);


--
-- Name: baserow_premium_piechartseriesconfig_series_id_0271cf93; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_piechartseriesconfig_series_id_0271cf93 ON public.baserow_premium_piechartseriesconfig USING btree (series_id);


--
-- Name: baserow_premium_piechartseriesconfig_widget_id_29840303; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_piechartseriesconfig_widget_id_29840303 ON public.baserow_premium_piechartseriesconfig USING btree (widget_id);


--
-- Name: baserow_premium_piechartwidget_data_source_id_e30f445d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_piechartwidget_data_source_id_e30f445d ON public.baserow_premium_piechartwidget USING btree (data_source_id);


--
-- Name: baserow_premium_rowcommentsnotificationmode_table_id_84cd1b14; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_rowcommentsnotificationmode_table_id_84cd1b14 ON public.baserow_premium_rowcommentsnotificationmode USING btree (table_id);


--
-- Name: baserow_premium_rowcommentsnotificationmode_user_id_af189acd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX baserow_premium_rowcommentsnotificationmode_user_id_af189acd ON public.baserow_premium_rowcommentsnotificationmode USING btree (user_id);


--
-- Name: builder_aiagentworkflowaction_service_id_a2968d41; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_aiagentworkflowaction_service_id_a2968d41 ON public.builder_aiagentworkflowaction USING btree (service_id);


--
-- Name: builder_builder_favicon_file_id_d767496c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_builder_favicon_file_id_d767496c ON public.builder_builder USING btree (favicon_file_id);


--
-- Name: builder_builderworkflowaction_content_type_id_b148baee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_builderworkflowaction_content_type_id_b148baee ON public.builder_builderworkflowaction USING btree (content_type_id);


--
-- Name: builder_builderworkflowaction_element_id_5e4bdf53; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_builderworkflowaction_element_id_5e4bdf53 ON public.builder_builderworkflowaction USING btree (element_id);


--
-- Name: builder_builderworkflowaction_page_id_cd71c70c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_builderworkflowaction_page_id_cd71c70c ON public.builder_builderworkflowaction USING btree (page_id);


--
-- Name: builder_collectionelementpropertyoptions_element_id_60a376d2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_collectionelementpropertyoptions_element_id_60a376d2 ON public.builder_collectionelementpropertyoptions USING btree (element_id);


--
-- Name: builder_corecsvfilereaderworkflowaction_service_id_cf7c15fc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_corecsvfilereaderworkflowaction_service_id_cf7c15fc ON public.builder_corecsvfilereaderworkflowaction USING btree (service_id);


--
-- Name: builder_corehttprequestworkflowaction_service_id_206cfc6f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_corehttprequestworkflowaction_service_id_206cfc6f ON public.builder_corehttprequestworkflowaction USING btree (service_id);


--
-- Name: builder_coresmtpemailworkflowaction_service_id_8d3e84f4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_coresmtpemailworkflowaction_service_id_8d3e84f4 ON public.builder_coresmtpemailworkflowaction USING btree (service_id);


--
-- Name: builder_corestartworkflowworkflowaction_service_id_7d0127ba; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_corestartworkflowworkflowaction_service_id_7d0127ba ON public.builder_corestartworkflowworkflowaction USING btree (service_id);


--
-- Name: builder_dat_page_id_5f7455_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_dat_page_id_5f7455_idx ON public.builder_datasource USING btree (page_id, "order", id);


--
-- Name: builder_datasource_page_id_cec9a398; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_datasource_page_id_cec9a398 ON public.builder_datasource USING btree (page_id);


--
-- Name: builder_datasource_trashed_df1311b2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_datasource_trashed_df1311b2 ON public.builder_datasource USING btree (trashed);


--
-- Name: builder_domain_builder_id_dcaa7438; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_domain_builder_id_dcaa7438 ON public.builder_domain USING btree (builder_id);


--
-- Name: builder_domain_content_type_id_3cc79455; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_domain_content_type_id_3cc79455 ON public.builder_domain USING btree (content_type_id);


--
-- Name: builder_domain_domain_name_5b0e56eb_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_domain_domain_name_5b0e56eb_like ON public.builder_domain USING btree (domain_name varchar_pattern_ops);


--
-- Name: builder_domain_trashed_d5b1007d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_domain_trashed_d5b1007d ON public.builder_domain USING btree (trashed);


--
-- Name: builder_dropdownelementoption_dropdown_id_286bc164; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_dropdownelementoption_dropdown_id_286bc164 ON public.builder_choiceelementoption USING btree (choice_id);


--
-- Name: builder_duplicatepagejob_original_page_id_de957244; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_duplicatepagejob_original_page_id_de957244 ON public.builder_duplicatepagejob USING btree (original_page_id);


--
-- Name: builder_element_content_type_id_4b196482; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_element_content_type_id_4b196482 ON public.builder_element USING btree (content_type_id);


--
-- Name: builder_element_page_id_97ce22ab; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_element_page_id_97ce22ab ON public.builder_element USING btree (page_id);


--
-- Name: builder_element_parent_element_id_422d0390; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_element_parent_element_id_422d0390 ON public.builder_element USING btree (parent_element_id);


--
-- Name: builder_element_role_type_bf2f29bc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_element_role_type_bf2f29bc ON public.builder_element USING btree (role_type);


--
-- Name: builder_element_role_type_bf2f29bc_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_element_role_type_bf2f29bc_like ON public.builder_element USING btree (role_type varchar_pattern_ops);


--
-- Name: builder_element_style_background_file_id_f99b4091; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_element_style_background_file_id_f99b4091 ON public.builder_element USING btree (style_background_file_id);


--
-- Name: builder_element_trashed_5e308264; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_element_trashed_5e308264 ON public.builder_element USING btree (trashed);


--
-- Name: builder_element_visibility_f694419d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_element_visibility_f694419d ON public.builder_element USING btree (visibility);


--
-- Name: builder_element_visibility_f694419d_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_element_visibility_f694419d_like ON public.builder_element USING btree (visibility varchar_pattern_ops);


--
-- Name: builder_footerelement_pages_footerelement_id_41c64a4d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_footerelement_pages_footerelement_id_41c64a4d ON public.builder_footerelement_pages USING btree (footerelement_id);


--
-- Name: builder_footerelement_pages_page_id_04cb6ca1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_footerelement_pages_page_id_04cb6ca1 ON public.builder_footerelement_pages USING btree (page_id);


--
-- Name: builder_headerelement_pages_headerelement_id_251194af; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_headerelement_pages_headerelement_id_251194af ON public.builder_headerelement_pages USING btree (headerelement_id);


--
-- Name: builder_headerelement_pages_page_id_e26b6226; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_headerelement_pages_page_id_e26b6226 ON public.builder_headerelement_pages USING btree (page_id);


--
-- Name: builder_imageelement_image_file_id_ebab311b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_imageelement_image_file_id_ebab311b ON public.builder_imageelement USING btree (image_file_id);


--
-- Name: builder_linkelement_navigate_to_page_id_4002370e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_linkelement_navigate_to_page_id_4002370e ON public.builder_linkelement USING btree (navigate_to_page_id);


--
-- Name: builder_localbaserowcreate_service_id_e700e56f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_localbaserowcreate_service_id_e700e56f ON public.builder_localbaserowcreaterowsworkflowaction USING btree (service_id);


--
-- Name: builder_localbaserowcreaterowworkflowaction_service_id_7e512d51; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_localbaserowcreaterowworkflowaction_service_id_7e512d51 ON public.builder_localbaserowcreaterowworkflowaction USING btree (service_id);


--
-- Name: builder_localbaserowdeleterowworkflowaction_service_id_50d4be5b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_localbaserowdeleterowworkflowaction_service_id_50d4be5b ON public.builder_localbaserowdeleterowworkflowaction USING btree (service_id);


--
-- Name: builder_localbaserowupdate_service_id_e74eaf8d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_localbaserowupdate_service_id_e74eaf8d ON public.builder_localbaserowupdaterowsworkflowaction USING btree (service_id);


--
-- Name: builder_localbaserowupdaterowworkflowaction_service_id_bc7906e7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_localbaserowupdaterowworkflowaction_service_id_bc7906e7 ON public.builder_localbaserowupdaterowworkflowaction USING btree (service_id);


--
-- Name: builder_menuelement_menu_items_menuelement_id_e5b36ce0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_menuelement_menu_items_menuelement_id_e5b36ce0 ON public.builder_menuelement_menu_items USING btree (menuelement_id);


--
-- Name: builder_menuelement_menu_items_menuitemelement_id_efaec61d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_menuelement_menu_items_menuitemelement_id_efaec61d ON public.builder_menuelement_menu_items USING btree (menuitemelement_id);


--
-- Name: builder_menuitemelement_navigate_to_page_id_f4037457; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_menuitemelement_navigate_to_page_id_f4037457 ON public.builder_menuitemelement USING btree (navigate_to_page_id);


--
-- Name: builder_menuitemelement_parent_menu_item_id_ec829f4b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_menuitemelement_parent_menu_item_id_ec829f4b ON public.builder_menuitemelement USING btree (parent_menu_item_id);


--
-- Name: builder_openpageworkflowaction_navigate_to_page_id_7f0c6c81; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_openpageworkflowaction_navigate_to_page_id_7f0c6c81 ON public.builder_openpageworkflowaction USING btree (navigate_to_page_id);


--
-- Name: builder_pag_builder_da0520_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_pag_builder_da0520_idx ON public.builder_page USING btree (builder_id, shared DESC, "order");


--
-- Name: builder_pag_shared_9280eb_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_pag_shared_9280eb_idx ON public.builder_page USING btree (shared DESC, "order");


--
-- Name: builder_page_builder_id_b7d24d63; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_page_builder_id_b7d24d63 ON public.builder_page USING btree (builder_id);


--
-- Name: builder_page_role_type_62e76e70; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_page_role_type_62e76e70 ON public.builder_page USING btree (role_type);


--
-- Name: builder_page_role_type_62e76e70_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_page_role_type_62e76e70_like ON public.builder_page USING btree (role_type varchar_pattern_ops);


--
-- Name: builder_page_trashed_f5cb2d8e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_page_trashed_f5cb2d8e ON public.builder_page USING btree (trashed);


--
-- Name: builder_page_visibility_684c02b0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_page_visibility_684c02b0 ON public.builder_page USING btree (visibility);


--
-- Name: builder_page_visibility_684c02b0_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_page_visibility_684c02b0_like ON public.builder_page USING btree (visibility varchar_pattern_ops);


--
-- Name: builder_pagethemeconfigblock_page_background_file_id_44535b73; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_pagethemeconfigblock_page_background_file_id_44535b73 ON public.builder_pagethemeconfigblock USING btree (page_background_file_id);


--
-- Name: builder_publishdomainjob_domain_id_f81e0d37; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_publishdomainjob_domain_id_f81e0d37 ON public.builder_publishdomainjob USING btree (domain_id);


--
-- Name: builder_recordselectorelement_data_source_id_91fadd6f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_recordselectorelement_data_source_id_91fadd6f ON public.builder_recordselectorelement USING btree (data_source_id);


--
-- Name: builder_refreshdatasourceworkflowaction_data_source_id_b4f22517; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_refreshdatasourceworkflowaction_data_source_id_b4f22517 ON public.builder_refreshdatasourceworkflowaction USING btree (data_source_id);


--
-- Name: builder_repeatelement_data_source_id_3d03270d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_repeatelement_data_source_id_3d03270d ON public.builder_repeatelement USING btree (data_source_id);


--
-- Name: builder_slackwritemessageworkflowaction_service_id_830ca442; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_slackwritemessageworkflowaction_service_id_830ca442 ON public.builder_slackwritemessageworkflowaction USING btree (service_id);


--
-- Name: builder_tableelement_data_source_id_87426f7d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_tableelement_data_source_id_87426f7d ON public.builder_tableelement USING btree (data_source_id);


--
-- Name: builder_tableelement_fields_collectionfield_id_201f0926; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_tableelement_fields_collectionfield_id_201f0926 ON public.builder_tableelement_fields USING btree (collectionfield_id);


--
-- Name: builder_tableelement_fields_tableelement_id_112738d0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX builder_tableelement_fields_tableelement_id_112738d0 ON public.builder_tableelement_fields USING btree (tableelement_id);


--
-- Name: core_action_action_group_aa302f37; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_action_group_aa302f37 ON public.core_action USING btree (action_group);


--
-- Name: core_action_created_cd208a_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_created_cd208a_idx ON public.core_action USING btree (created_on DESC, id DESC);


--
-- Name: core_action_group_id_68ee3154; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_group_id_68ee3154 ON public.core_action USING btree (workspace_id);


--
-- Name: core_action_scope_54d15a7f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_scope_54d15a7f ON public.core_action USING btree (scope);


--
-- Name: core_action_scope_54d15a7f_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_scope_54d15a7f_like ON public.core_action USING btree (scope text_pattern_ops);


--
-- Name: core_action_session_2011a599; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_session_2011a599 ON public.core_action USING btree (session);


--
-- Name: core_action_session_2011a599_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_session_2011a599_like ON public.core_action USING btree (session text_pattern_ops);


--
-- Name: core_action_type_45474a39; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_type_45474a39 ON public.core_action USING btree (type);


--
-- Name: core_action_type_45474a39_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_type_45474a39_like ON public.core_action USING btree (type text_pattern_ops);


--
-- Name: core_action_undone__215f89_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_undone__215f89_idx ON public.core_action USING btree (undone_at DESC, id DESC);


--
-- Name: core_action_undone_at_3e8401c4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_undone_at_3e8401c4 ON public.core_action USING btree (undone_at);


--
-- Name: core_action_updated_63da87_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_updated_63da87_idx ON public.core_action USING btree (updated_on, id);


--
-- Name: core_action_user_id_eed182ff; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_action_user_id_eed182ff ON public.core_action USING btree (user_id);


--
-- Name: core_appauthprovider_content_type_id_55bde76e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_appauthprovider_content_type_id_55bde76e ON public.core_appauthprovider USING btree (content_type_id);


--
-- Name: core_appauthprovider_user_source_id_ec8d3566; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_appauthprovider_user_source_id_ec8d3566 ON public.core_appauthprovider USING btree (user_source_id);


--
-- Name: core_application_content_type_id_472cc32f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_application_content_type_id_472cc32f ON public.core_application USING btree (content_type_id);


--
-- Name: core_application_group_id_6a80d0d4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_application_group_id_6a80d0d4 ON public.core_application USING btree (workspace_id);


--
-- Name: core_application_installed_from_template_id_a539253e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_application_installed_from_template_id_a539253e ON public.core_application USING btree (installed_from_template_id);


--
-- Name: core_application_trashed_dd8aff19; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_application_trashed_dd8aff19 ON public.core_application USING btree (trashed);


--
-- Name: core_authprovidermodel_content_type_id_a7ec10bb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_authprovidermodel_content_type_id_a7ec10bb ON public.core_authprovidermodel USING btree (content_type_id);


--
-- Name: core_authprovidermodel_users_authprovidermodel_id_932b69eb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_authprovidermodel_users_authprovidermodel_id_932b69eb ON public.core_authprovidermodel_users USING btree (authprovidermodel_id);


--
-- Name: core_authprovidermodel_users_user_id_0af0c09f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_authprovidermodel_users_user_id_0af0c09f ON public.core_authprovidermodel_users USING btree (user_id);


--
-- Name: core_blacklistedtoken_hashed_token_0d7e0afb_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_blacklistedtoken_hashed_token_0d7e0afb_like ON public.core_blacklistedtoken USING btree (hashed_token varchar_pattern_ops);


--
-- Name: core_createsnapshotjob_snapshot_id_994c6005; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_createsnapshotjob_snapshot_id_994c6005 ON public.core_createsnapshotjob USING btree (snapshot_id);


--
-- Name: core_duplicateapplicationjob_original_application_id_09218c73; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_duplicateapplicationjob_original_application_id_09218c73 ON public.core_duplicateapplicationjob USING btree (original_application_id);


--
-- Name: core_exportapplicationsjob_resource_id_9f185c4d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_exportapplicationsjob_resource_id_9f185c4d ON public.core_exportapplicationsjob USING btree (resource_id);


--
-- Name: core_exportapplicationsjob_workspace_id_8d4c8e7d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_exportapplicationsjob_workspace_id_8d4c8e7d ON public.core_exportapplicationsjob USING btree (workspace_id);


--
-- Name: core_group_trashed_8c6da2af; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_group_trashed_8c6da2af ON public.core_workspace USING btree (trashed);


--
-- Name: core_groupinvitation_email_05b2caa9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_groupinvitation_email_05b2caa9 ON public.core_workspaceinvitation USING btree (email);


--
-- Name: core_groupinvitation_email_05b2caa9_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_groupinvitation_email_05b2caa9_like ON public.core_workspaceinvitation USING btree (email varchar_pattern_ops);


--
-- Name: core_groupinvitation_group_id_d794f45a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_groupinvitation_group_id_d794f45a ON public.core_workspaceinvitation USING btree (workspace_id);


--
-- Name: core_groupinvitation_invited_by_id_ecbae904; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_groupinvitation_invited_by_id_ecbae904 ON public.core_workspaceinvitation USING btree (invited_by_id);


--
-- Name: core_groupuser_group_id_e7bdfd65; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_groupuser_group_id_e7bdfd65 ON public.core_workspaceuser USING btree (workspace_id);


--
-- Name: core_groupuser_user_id_3e69dc39; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_groupuser_user_id_3e69dc39 ON public.core_workspaceuser USING btree (user_id);


--
-- Name: core_importapplicationsjob_resource_id_604c7bda; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_importapplicationsjob_resource_id_604c7bda ON public.core_importapplicationsjob USING btree (resource_id);


--
-- Name: core_importapplicationsjob_workspace_id_08a8bd7d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_importapplicationsjob_workspace_id_08a8bd7d ON public.core_importapplicationsjob USING btree (workspace_id);


--
-- Name: core_importexportresource_created_by_id_37d8fbc4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_importexportresource_created_by_id_37d8fbc4 ON public.core_importexportresource USING btree (created_by_id);


--
-- Name: core_importexportresource_uuid_b275fe46; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_importexportresource_uuid_b275fe46 ON public.core_importexportresource USING btree (uuid);


--
-- Name: core_installtemplatejob_group_id_a0fd54f1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_installtemplatejob_group_id_a0fd54f1 ON public.core_installtemplatejob USING btree (workspace_id);


--
-- Name: core_installtemplatejob_template_id_1b0e3630; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_installtemplatejob_template_id_1b0e3630 ON public.core_installtemplatejob USING btree (template_id);


--
-- Name: core_integration_application_id_818d7adb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_integration_application_id_818d7adb ON public.core_integration USING btree (application_id);


--
-- Name: core_integration_content_type_id_99657d37; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_integration_content_type_id_99657d37 ON public.core_integration USING btree (content_type_id);


--
-- Name: core_integration_trashed_c6e93dbc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_integration_trashed_c6e93dbc ON public.core_integration USING btree (trashed);


--
-- Name: core_job_content_type_id_6aeb9e39; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_job_content_type_id_6aeb9e39 ON public.core_job USING btree (content_type_id);


--
-- Name: core_job_state_8e799e02; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_job_state_8e799e02 ON public.core_job USING btree (state);


--
-- Name: core_job_state_8e799e02_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_job_state_8e799e02_like ON public.core_job USING btree (state varchar_pattern_ops);


--
-- Name: core_job_updated_e7a478_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_job_updated_e7a478_idx ON public.core_job USING btree (updated_on DESC);


--
-- Name: core_job_user_id_b69eefda; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_job_user_id_b69eefda ON public.core_job USING btree (user_id);


--
-- Name: core_mcpendpoint_key_44dfc43d_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_mcpendpoint_key_44dfc43d_like ON public.core_mcpendpoint USING btree (key varchar_pattern_ops);


--
-- Name: core_mcpendpoint_user_id_3ee955c7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_mcpendpoint_user_id_3ee955c7 ON public.core_mcpendpoint USING btree (user_id);


--
-- Name: core_mcpendpoint_workspace_id_431218c6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_mcpendpoint_workspace_id_431218c6 ON public.core_mcpendpoint USING btree (workspace_id);


--
-- Name: core_notifi_created_4b2233_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_notifi_created_4b2233_idx ON public.core_notificationrecipient USING btree (created_on DESC, id DESC);


--
-- Name: core_notifi_created_7f4b88_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_notifi_created_7f4b88_idx ON public.core_notification USING btree (created_on DESC, id DESC);


--
-- Name: core_notification_sender_id_7af58206; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_notification_sender_id_7af58206 ON public.core_notification USING btree (sender_id);


--
-- Name: core_notification_workspace_id_99158c25; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_notification_workspace_id_99158c25 ON public.core_notification USING btree (workspace_id);


--
-- Name: core_notificationrecipient_notification_id_48f0f193; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_notificationrecipient_notification_id_48f0f193 ON public.core_notificationrecipient USING btree (notification_id);


--
-- Name: core_notificationrecipient_recipient_id_cf073056; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_notificationrecipient_recipient_id_cf073056 ON public.core_notificationrecipient USING btree (recipient_id);


--
-- Name: core_operation_name_c2257539_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_operation_name_c2257539_like ON public.core_operation USING btree (name varchar_pattern_ops);


--
-- Name: core_restoresnapshotjob_snapshot_id_76cd92b9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_restoresnapshotjob_snapshot_id_76cd92b9 ON public.core_restoresnapshotjob USING btree (snapshot_id);


--
-- Name: core_schemaoperation_content_type_id_da4058fb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_schemaoperation_content_type_id_da4058fb ON public.core_schemaoperation USING btree (content_type_id);


--
-- Name: core_service_content_type_id_a9ea8d7e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_service_content_type_id_a9ea8d7e ON public.core_service USING btree (content_type_id);


--
-- Name: core_service_integration_id_396ff441; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_service_integration_id_396ff441 ON public.core_service USING btree (integration_id);


--
-- Name: core_service_trashed_a40f82a9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_service_trashed_a40f82a9 ON public.core_service USING btree (trashed);


--
-- Name: core_settings_co_branding_logo_id_1d9838c7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_settings_co_branding_logo_id_1d9838c7 ON public.core_settings USING btree (co_branding_logo_id);


--
-- Name: core_settings_instance_id_287a1f0f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_settings_instance_id_287a1f0f ON public.core_settings USING btree (instance_id);


--
-- Name: core_settings_instance_id_287a1f0f_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_settings_instance_id_287a1f0f_like ON public.core_settings USING btree (instance_id varchar_pattern_ops);


--
-- Name: core_snapshot_created_by_id_6dbd6149; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_snapshot_created_by_id_6dbd6149 ON public.core_snapshot USING btree (created_by_id);


--
-- Name: core_snapshot_snapshot_from_application_id_c2b7fb78; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_snapshot_snapshot_from_application_id_c2b7fb78 ON public.core_snapshot USING btree (snapshot_from_application_id);


--
-- Name: core_snapshot_snapshot_to_application_id_0ce2529c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_snapshot_snapshot_to_application_id_0ce2529c ON public.core_snapshot USING btree (snapshot_to_application_id);


--
-- Name: core_template_categories_template_id_2ab2048f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_template_categories_template_id_2ab2048f ON public.core_template_categories USING btree (template_id);


--
-- Name: core_template_categories_templatecategory_id_da998bfd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_template_categories_templatecategory_id_da998bfd ON public.core_template_categories USING btree (templatecategory_id);


--
-- Name: core_template_group_id_60005412; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_template_group_id_60005412 ON public.core_template USING btree (workspace_id);


--
-- Name: core_template_slug_35fc20be; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_template_slug_35fc20be ON public.core_template USING btree (slug);


--
-- Name: core_template_slug_35fc20be_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_template_slug_35fc20be_like ON public.core_template USING btree (slug varchar_pattern_ops);


--
-- Name: core_totpusedcode_user_id_7a35bd2c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_totpusedcode_user_id_7a35bd2c ON public.core_totpusedcode USING btree (user_id);


--
-- Name: core_trashe_trashed_0bf61a_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_trashe_trashed_0bf61a_idx ON public.core_trashentry USING btree (trashed_at DESC, trash_item_type, workspace_id, application_id);


--
-- Name: core_trashentry_application_id_38c0c0a7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_trashentry_application_id_38c0c0a7 ON public.core_trashentry USING btree (application_id);


--
-- Name: core_trashentry_trash_item_owner_id_8ebc2521; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_trashentry_trash_item_owner_id_8ebc2521 ON public.core_trashentry USING btree (trash_item_owner_id);


--
-- Name: core_trashentry_user_who_trashed_id_9c115f8e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_trashentry_user_who_trashed_id_9c115f8e ON public.core_trashentry USING btree (user_who_trashed_id);


--
-- Name: core_trashentry_workspace_id_ed3bd1dd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_trashentry_workspace_id_ed3bd1dd ON public.core_trashentry USING btree (workspace_id);


--
-- Name: core_twofactorauthprovidermodel_content_type_id_539a71bc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_twofactorauthprovidermodel_content_type_id_539a71bc ON public.core_twofactorauthprovidermodel USING btree (content_type_id);


--
-- Name: core_twofactorauthrecoverycode_user_id_9e3d96af; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_twofactorauthrecoverycode_user_id_9e3d96af ON public.core_twofactorauthrecoverycode USING btree (user_id);


--
-- Name: core_userfile_sha256_hash_f6305017; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_userfile_sha256_hash_f6305017 ON public.core_userfile USING btree (sha256_hash);


--
-- Name: core_userfile_sha256_hash_f6305017_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_userfile_sha256_hash_f6305017_like ON public.core_userfile USING btree (sha256_hash varchar_pattern_ops);


--
-- Name: core_userfile_unique_a8ae2bad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_userfile_unique_a8ae2bad ON public.core_userfile USING btree ("unique");


--
-- Name: core_userfile_unique_a8ae2bad_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_userfile_unique_a8ae2bad_like ON public.core_userfile USING btree ("unique" varchar_pattern_ops);


--
-- Name: core_userfile_uploaded_by_id_9eaef00e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_userfile_uploaded_by_id_9eaef00e ON public.core_userfile USING btree (uploaded_by_id);


--
-- Name: core_userlogentry_actor_id_fb0b2f94; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_userlogentry_actor_id_fb0b2f94 ON public.core_userlogentry USING btree (actor_id);


--
-- Name: core_usersource_application_id_36893a8a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_usersource_application_id_36893a8a ON public.core_usersource USING btree (application_id);


--
-- Name: core_usersource_content_type_id_c1933b84; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_usersource_content_type_id_c1933b84 ON public.core_usersource USING btree (content_type_id);


--
-- Name: core_usersource_integration_id_90c21eaa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_usersource_integration_id_90c21eaa ON public.core_usersource USING btree (integration_id);


--
-- Name: core_usersource_trashed_20fef695; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_usersource_trashed_20fef695 ON public.core_usersource USING btree (trashed);


--
-- Name: core_usersource_uid_0ba94fb4_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX core_usersource_uid_0ba94fb4_like ON public.core_usersource USING btree (uid text_pattern_ops);


--
-- Name: dashboard_dashboarddatasource_dashboard_id_7097f356; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dashboard_dashboarddatasource_dashboard_id_7097f356 ON public.dashboard_dashboarddatasource USING btree (dashboard_id);


--
-- Name: dashboard_dashboarddatasource_trashed_065b3d2d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dashboard_dashboarddatasource_trashed_065b3d2d ON public.dashboard_dashboarddatasource USING btree (trashed);


--
-- Name: dashboard_summarywidget_data_source_id_918e7169; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dashboard_summarywidget_data_source_id_918e7169 ON public.dashboard_summarywidget USING btree (data_source_id);


--
-- Name: dashboard_widget_content_type_id_c2b8e107; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dashboard_widget_content_type_id_c2b8e107 ON public.dashboard_widget USING btree (content_type_id);


--
-- Name: dashboard_widget_dashboard_id_d8c3f7af; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dashboard_widget_dashboard_id_d8c3f7af ON public.dashboard_widget USING btree (dashboard_id);


--
-- Name: dashboard_widget_trashed_76484e18; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dashboard_widget_trashed_76484e18 ON public.dashboard_widget USING btree (trashed);


--
-- Name: database_airtableimportjob_database_id_cc693ce8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_airtableimportjob_database_id_cc693ce8 ON public.database_airtableimportjob USING btree (database_id);


--
-- Name: database_airtableimportjob_group_id_51162106; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_airtableimportjob_group_id_51162106 ON public.database_airtableimportjob USING btree (workspace_id);


--
-- Name: database_calendarview_date_field_id_f7baa49c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_calendarview_date_field_id_f7baa49c ON public.database_calendarview USING btree (date_field_id);


--
-- Name: database_calendarview_ical_public_ebc5c6e5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_calendarview_ical_public_ebc5c6e5 ON public.database_calendarview USING btree (ical_public);


--
-- Name: database_calendarview_ical_slug_c0b4ceaf_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_calendarview_ical_slug_c0b4ceaf_like ON public.database_calendarview USING btree (ical_slug varchar_pattern_ops);


--
-- Name: database_calendarviewfieldoptions_calendar_view_id_d6160dbb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_calendarviewfieldoptions_calendar_view_id_d6160dbb ON public.database_calendarviewfieldoptions USING btree (calendar_view_id);


--
-- Name: database_calendarviewfieldoptions_field_id_b4091352; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_calendarviewfieldoptions_field_id_b4091352 ON public.database_calendarviewfieldoptions USING btree (field_id);


--
-- Name: database_countfield_through_field_id_47754f72; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_countfield_through_field_id_47754f72 ON public.database_countfield USING btree (through_field_id);


--
-- Name: database_datasync_content_type_id_518adc1d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_datasync_content_type_id_518adc1d ON public.database_datasync USING btree (content_type_id);


--
-- Name: database_datasyncsyncedproperty_data_sync_id_c9237ce1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_datasyncsyncedproperty_data_sync_id_c9237ce1 ON public.database_datasyncsyncedproperty USING btree (data_sync_id);


--
-- Name: database_datasyncsyncedproperty_field_id_4205e92c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_datasyncsyncedproperty_field_id_4205e92c ON public.database_datasyncsyncedproperty USING btree (field_id);


--
-- Name: database_duplicatefieldjob_original_field_id_a8d6be5d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_duplicatefieldjob_original_field_id_a8d6be5d ON public.database_duplicatefieldjob USING btree (original_field_id);


--
-- Name: database_duplicatetablejob_original_table_id_d3c02305; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_duplicatetablejob_original_table_id_d3c02305 ON public.database_duplicatetablejob USING btree (original_table_id);


--
-- Name: database_ex_created_f04904_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_ex_created_f04904_idx ON public.database_exportjob USING btree (created_at, user_id, state);


--
-- Name: database_exportjob_table_id_9120c18e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_exportjob_table_id_9120c18e ON public.database_exportjob USING btree (table_id);


--
-- Name: database_exportjob_user_id_f9802097; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_exportjob_user_id_f9802097 ON public.database_exportjob USING btree (user_id);


--
-- Name: database_exportjob_view_id_a1d8052f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_exportjob_view_id_a1d8052f ON public.database_exportjob USING btree (view_id);


--
-- Name: database_field_content_type_id_3e7c32c9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_field_content_type_id_3e7c32c9 ON public.database_field USING btree (content_type_id);


--
-- Name: database_field_name_d14dee8e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_field_name_d14dee8e ON public.database_field USING btree (name);


--
-- Name: database_field_name_d14dee8e_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_field_name_d14dee8e_like ON public.database_field USING btree (name varchar_pattern_ops);


--
-- Name: database_field_table_id_10109215; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_field_table_id_10109215 ON public.database_field USING btree (table_id);


--
-- Name: database_field_trashed_19e713f8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_field_trashed_19e713f8 ON public.database_field USING btree (trashed);


--
-- Name: database_fieldconstraint_field_id_ab382ba7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_fieldconstraint_field_id_ab382ba7 ON public.database_fieldconstraint USING btree (field_id);


--
-- Name: database_fieldconstraint_trashed_ba426999; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_fieldconstraint_trashed_ba426999 ON public.database_fieldconstraint USING btree (trashed);


--
-- Name: database_fielddependency_broken_reference_field_n_398cbe6f_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_fielddependency_broken_reference_field_n_398cbe6f_like ON public.database_fielddependency USING btree (broken_reference_field_name text_pattern_ops);


--
-- Name: database_fielddependency_broken_reference_field_name_398cbe6f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_fielddependency_broken_reference_field_name_398cbe6f ON public.database_fielddependency USING btree (broken_reference_field_name);


--
-- Name: database_fielddependency_dependant_id_ca4b13bd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_fielddependency_dependant_id_ca4b13bd ON public.database_fielddependency USING btree (dependant_id);


--
-- Name: database_fielddependency_dependency_id_3dd1c05d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_fielddependency_dependency_id_3dd1c05d ON public.database_fielddependency USING btree (dependency_id);


--
-- Name: database_fielddependency_via_id_3ab567a8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_fielddependency_via_id_3ab567a8 ON public.database_fielddependency USING btree (via_id);


--
-- Name: database_fieldrule_content_type_id_8783421e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_fieldrule_content_type_id_8783421e ON public.database_fieldrule USING btree (content_type_id);


--
-- Name: database_fieldrule_table_id_b6fb8fb1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_fieldrule_table_id_b6fb8fb1 ON public.database_fieldrule USING btree (table_id);


--
-- Name: database_fileimportjob_database_id_0566cd2d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_fileimportjob_database_id_0566cd2d ON public.database_fileimportjob USING btree (database_id);


--
-- Name: database_fileimportjob_table_id_7f90d810; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_fileimportjob_table_id_7f90d810 ON public.database_fileimportjob USING btree (table_id);


--
-- Name: database_formview_cover_image_id_19e4ffdc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formview_cover_image_id_19e4ffdc ON public.database_formview USING btree (cover_image_id);


--
-- Name: database_formview_logo_image_id_efa8caf1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formview_logo_image_id_efa8caf1 ON public.database_formview USING btree (logo_image_id);


--
-- Name: database_formview_users_to_formview_id_0228f44e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formview_users_to_formview_id_0228f44e ON public.database_formview_users_to_notify_on_submit USING btree (formview_id);


--
-- Name: database_formview_users_to_notify_on_submit_user_id_a0179cf0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formview_users_to_notify_on_submit_user_id_a0179cf0 ON public.database_formview_users_to_notify_on_submit USING btree (user_id);


--
-- Name: database_formvieweditrowfield_form_view_id_8ac4e7d8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formvieweditrowfield_form_view_id_8ac4e7d8 ON public.database_formvieweditrowfield USING btree (form_view_id);


--
-- Name: database_formviewfieldopti_field_option_id_a9ffa2b5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formviewfieldopti_field_option_id_a9ffa2b5 ON public.database_formviewfieldoptionsconditiongroup USING btree (field_option_id);


--
-- Name: database_formviewfieldopti_form_view_field_options_id_e7eebddb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formviewfieldopti_form_view_field_options_id_e7eebddb ON public.database_formviewfieldoptionsallowedselectoptions USING btree (form_view_field_options_id);


--
-- Name: database_formviewfieldopti_parent_group_id_4f199881; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formviewfieldopti_parent_group_id_4f199881 ON public.database_formviewfieldoptionsconditiongroup USING btree (parent_group_id);


--
-- Name: database_formviewfieldopti_select_option_id_9bd1c913; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formviewfieldopti_select_option_id_9bd1c913 ON public.database_formviewfieldoptionsallowedselectoptions USING btree (select_option_id);


--
-- Name: database_formviewfieldoptions_field_id_37f2f750; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formviewfieldoptions_field_id_37f2f750 ON public.database_formviewfieldoptions USING btree (field_id);


--
-- Name: database_formviewfieldoptions_form_view_id_374bdec5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formviewfieldoptions_form_view_id_374bdec5 ON public.database_formviewfieldoptions USING btree (form_view_id);


--
-- Name: database_formviewfieldoptionscondition_field_id_2cdb1588; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formviewfieldoptionscondition_field_id_2cdb1588 ON public.database_formviewfieldoptionscondition USING btree (field_id);


--
-- Name: database_formviewfieldoptionscondition_field_option_id_b48a9e1f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formviewfieldoptionscondition_field_option_id_b48a9e1f ON public.database_formviewfieldoptionscondition USING btree (field_option_id);


--
-- Name: database_formviewfieldoptionscondition_group_id_ff7307cf; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_formviewfieldoptionscondition_group_id_ff7307cf ON public.database_formviewfieldoptionscondition USING btree (group_id);


--
-- Name: database_galleryview_card_cover_image_field_id_61ed6620; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_galleryview_card_cover_image_field_id_61ed6620 ON public.database_galleryview USING btree (card_cover_image_field_id);


--
-- Name: database_galleryviewfieldoptions_field_id_541e78db; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_galleryviewfieldoptions_field_id_541e78db ON public.database_galleryviewfieldoptions USING btree (field_id);


--
-- Name: database_galleryviewfieldoptions_gallery_view_id_622189d6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_galleryviewfieldoptions_gallery_view_id_622189d6 ON public.database_galleryviewfieldoptions USING btree (gallery_view_id);


--
-- Name: database_gridviewfieldoptions_field_id_5808d604; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_gridviewfieldoptions_field_id_5808d604 ON public.database_gridviewfieldoptions USING btree (field_id);


--
-- Name: database_gridviewfieldoptions_grid_view_id_b537505b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_gridviewfieldoptions_grid_view_id_b537505b ON public.database_gridviewfieldoptions USING btree (grid_view_id);


--
-- Name: database_kanbanview_card_cover_image_field_id_5bd91f16; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_kanbanview_card_cover_image_field_id_5bd91f16 ON public.database_kanbanview USING btree (card_cover_image_field_id);


--
-- Name: database_kanbanview_single_select_field_id_b06a8b52; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_kanbanview_single_select_field_id_b06a8b52 ON public.database_kanbanview USING btree (single_select_field_id);


--
-- Name: database_kanbanviewfieldoptions_field_id_257bb004; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_kanbanviewfieldoptions_field_id_257bb004 ON public.database_kanbanviewfieldoptions USING btree (field_id);


--
-- Name: database_kanbanviewfieldoptions_kanban_view_id_d7b70bb3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_kanbanviewfieldoptions_kanban_view_id_d7b70bb3 ON public.database_kanbanviewfieldoptions USING btree (kanban_view_id);


--
-- Name: database_linkrowfield_link_row_limit_selection_view_id_54c4559f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_linkrowfield_link_row_limit_selection_view_id_54c4559f ON public.database_linkrowfield USING btree (link_row_limit_selection_view_id);


--
-- Name: database_linkrowfield_link_row_related_field_id_0d56e726; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_linkrowfield_link_row_related_field_id_0d56e726 ON public.database_linkrowfield USING btree (link_row_related_field_id);


--
-- Name: database_linkrowfield_link_row_table_id_84dbb70f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_linkrowfield_link_row_table_id_84dbb70f ON public.database_linkrowfield USING btree (link_row_table_id);


--
-- Name: database_lookupfield_target_field_id_7c9df7fa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_lookupfield_target_field_id_7c9df7fa ON public.database_lookupfield USING btree (target_field_id);


--
-- Name: database_lookupfield_through_field_id_377bb9ac; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_lookupfield_through_field_id_377bb9ac ON public.database_lookupfield USING btree (through_field_id);


--
-- Name: database_multipleselect_46_multipleselectfield46selec_a67be1a7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_multipleselect_46_multipleselectfield46selec_a67be1a7 ON public.database_multipleselect_46 USING btree (multipleselectfield46selectoption_id);


--
-- Name: database_multipleselect_46_table7model_id_1704caa1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_multipleselect_46_table7model_id_1704caa1 ON public.database_multipleselect_46 USING btree (table7model_id);


--
-- Name: database_relation_1_table1model_id_35e6ef56; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_1_table1model_id_35e6ef56 ON public.database_relation_1 USING btree (table1model_id);


--
-- Name: database_relation_1_table4model_id_ef3673d2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_1_table4model_id_ef3673d2 ON public.database_relation_1 USING btree (table4model_id);


--
-- Name: database_relation_2_table1model_id_7479d399; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_2_table1model_id_7479d399 ON public.database_relation_2 USING btree (table1model_id);


--
-- Name: database_relation_2_table2model_id_be6f4a23; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_2_table2model_id_be6f4a23 ON public.database_relation_2 USING btree (table2model_id);


--
-- Name: database_relation_3_table1model_id_99fb8aed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_3_table1model_id_99fb8aed ON public.database_relation_3 USING btree (table1model_id);


--
-- Name: database_relation_3_table6model_id_8f0ea557; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_3_table6model_id_8f0ea557 ON public.database_relation_3 USING btree (table6model_id);


--
-- Name: database_relation_4_table1model_id_247d2ec0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_4_table1model_id_247d2ec0 ON public.database_relation_4 USING btree (table1model_id);


--
-- Name: database_relation_4_table5model_id_1f71bdea; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_4_table5model_id_1f71bdea ON public.database_relation_4 USING btree (table5model_id);


--
-- Name: database_relation_5_table2model_id_5e9de74c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_5_table2model_id_5e9de74c ON public.database_relation_5 USING btree (table2model_id);


--
-- Name: database_relation_5_table3model_id_0c96fe4d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_5_table3model_id_0c96fe4d ON public.database_relation_5 USING btree (table3model_id);


--
-- Name: database_relation_6_table6model_id_af35d3fd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_6_table6model_id_af35d3fd ON public.database_relation_6 USING btree (table6model_id);


--
-- Name: database_relation_6_table7model_id_efc7bc72; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_6_table7model_id_efc7bc72 ON public.database_relation_6 USING btree (table7model_id);


--
-- Name: database_relation_7_table8model_id_5044390d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_7_table8model_id_5044390d ON public.database_relation_7 USING btree (table8model_id);


--
-- Name: database_relation_7_table9model_id_b3e55986; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_relation_7_table9model_id_b3e55986 ON public.database_relation_7 USING btree (table9model_id);


--
-- Name: database_ri_row_id_40f362_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_ri_row_id_40f362_idx ON public.database_richtextfieldmention USING btree (row_id, field_id);


--
-- Name: database_richtextfieldmention_field_id_eac6a7be; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_richtextfieldmention_field_id_eac6a7be ON public.database_richtextfieldmention USING btree (field_id);


--
-- Name: database_richtextfieldmention_marked_for_deletion_at_1b618b36; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_richtextfieldmention_marked_for_deletion_at_1b618b36 ON public.database_richtextfieldmention USING btree (marked_for_deletion_at);


--
-- Name: database_richtextfieldmention_table_id_08b90768; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_richtextfieldmention_table_id_08b90768 ON public.database_richtextfieldmention USING btree (table_id);


--
-- Name: database_richtextfieldmention_user_id_ee90bcaa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_richtextfieldmention_user_id_ee90bcaa ON public.database_richtextfieldmention USING btree (user_id);


--
-- Name: database_ro_action__6ea699_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_ro_action__6ea699_idx ON public.database_rowhistory USING btree (action_timestamp);


--
-- Name: database_ro_table_i_5044cd_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_ro_table_i_5044cd_idx ON public.database_rowhistory USING btree (table_id, row_id, action_timestamp DESC, id DESC);


--
-- Name: database_ro_table_i_e8263d_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_ro_table_i_e8263d_idx ON public.database_rowcomment USING btree (table_id, row_id, created_on DESC);


--
-- Name: database_rollupfield_target_field_id_e514ae8b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_rollupfield_target_field_id_e514ae8b ON public.database_rollupfield USING btree (target_field_id);


--
-- Name: database_rollupfield_through_field_id_a35fa95f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_rollupfield_through_field_id_a35fa95f ON public.database_rollupfield USING btree (through_field_id);


--
-- Name: database_rowcomment_mentions_rowcomment_id_dc56cf9b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_rowcomment_mentions_rowcomment_id_dc56cf9b ON public.database_rowcomment_mentions USING btree (rowcomment_id);


--
-- Name: database_rowcomment_mentions_user_id_49a137b9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_rowcomment_mentions_user_id_49a137b9 ON public.database_rowcomment_mentions USING btree (user_id);


--
-- Name: database_rowcomment_table_id_5878d1c7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_rowcomment_table_id_5878d1c7 ON public.database_rowcomment USING btree (table_id);


--
-- Name: database_rowcomment_trashed_dfa6c79f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_rowcomment_trashed_dfa6c79f ON public.database_rowcomment USING btree (trashed);


--
-- Name: database_rowcomment_user_id_d0408bb6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_rowcomment_user_id_d0408bb6 ON public.database_rowcomment USING btree (user_id);


--
-- Name: database_rowhistory_table_id_8e564277; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_rowhistory_table_id_8e564277 ON public.database_rowhistory USING btree (table_id);


--
-- Name: database_selectoption_field_id_308591f6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_selectoption_field_id_308591f6 ON public.database_selectoption USING btree (field_id);


--
-- Name: database_syncdatasynctablejob_data_sync_id_07969c0e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_syncdatasynctablejob_data_sync_id_07969c0e ON public.database_syncdatasynctablejob USING btree (data_sync_id);


--
-- Name: database_table_1_created_by_id_2f6b74f8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_1_created_by_id_2f6b74f8 ON public.database_table_1 USING btree (created_by_id);


--
-- Name: database_table_1_field_2_305f65e7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_1_field_2_305f65e7 ON public.database_table_1 USING btree (field_2);


--
-- Name: database_table_1_last_modified_by_id_02856e13; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_1_last_modified_by_id_02856e13 ON public.database_table_1 USING btree (last_modified_by_id);


--
-- Name: database_table_1_trashed_6d38384e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_1_trashed_6d38384e ON public.database_table_1 USING btree (trashed);


--
-- Name: database_table_2_created_by_id_9a6f6237; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_2_created_by_id_9a6f6237 ON public.database_table_2 USING btree (created_by_id);


--
-- Name: database_table_2_field_11_a2dda1b1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_2_field_11_a2dda1b1 ON public.database_table_2 USING btree (field_11);


--
-- Name: database_table_2_field_13_78275b23; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_2_field_13_78275b23 ON public.database_table_2 USING btree (field_13);


--
-- Name: database_table_2_last_modified_by_id_ddf3ec6b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_2_last_modified_by_id_ddf3ec6b ON public.database_table_2 USING btree (last_modified_by_id);


--
-- Name: database_table_2_trashed_4d273b1f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_2_trashed_4d273b1f ON public.database_table_2 USING btree (trashed);


--
-- Name: database_table_3_created_by_id_4600d412; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_3_created_by_id_4600d412 ON public.database_table_3 USING btree (created_by_id);


--
-- Name: database_table_3_last_modified_by_id_be372a41; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_3_last_modified_by_id_be372a41 ON public.database_table_3 USING btree (last_modified_by_id);


--
-- Name: database_table_3_trashed_09845b1e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_3_trashed_09845b1e ON public.database_table_3 USING btree (trashed);


--
-- Name: database_table_4_created_by_id_c5ca8aa8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_4_created_by_id_c5ca8aa8 ON public.database_table_4 USING btree (created_by_id);


--
-- Name: database_table_4_last_modified_by_id_6fee86f7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_4_last_modified_by_id_6fee86f7 ON public.database_table_4 USING btree (last_modified_by_id);


--
-- Name: database_table_4_trashed_7df0a887; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_4_trashed_7df0a887 ON public.database_table_4 USING btree (trashed);


--
-- Name: database_table_5_created_by_id_07d50db0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_5_created_by_id_07d50db0 ON public.database_table_5 USING btree (created_by_id);


--
-- Name: database_table_5_last_modified_by_id_97967023; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_5_last_modified_by_id_97967023 ON public.database_table_5 USING btree (last_modified_by_id);


--
-- Name: database_table_5_trashed_77348de9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_5_trashed_77348de9 ON public.database_table_5 USING btree (trashed);


--
-- Name: database_table_6_created_by_id_3bbb2cf9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_6_created_by_id_3bbb2cf9 ON public.database_table_6 USING btree (created_by_id);


--
-- Name: database_table_6_last_modified_by_id_580baf28; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_6_last_modified_by_id_580baf28 ON public.database_table_6 USING btree (last_modified_by_id);


--
-- Name: database_table_6_trashed_2702527c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_6_trashed_2702527c ON public.database_table_6 USING btree (trashed);


--
-- Name: database_table_7_created_by_id_b7c75e0a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_7_created_by_id_b7c75e0a ON public.database_table_7 USING btree (created_by_id);


--
-- Name: database_table_7_last_modified_by_id_1cf2ad13; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_7_last_modified_by_id_1cf2ad13 ON public.database_table_7 USING btree (last_modified_by_id);


--
-- Name: database_table_7_trashed_4f901671; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_7_trashed_4f901671 ON public.database_table_7 USING btree (trashed);


--
-- Name: database_table_8_created_by_id_61687911; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_8_created_by_id_61687911 ON public.database_table_8 USING btree (created_by_id);


--
-- Name: database_table_8_field_60_ad97c906; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_8_field_60_ad97c906 ON public.database_table_8 USING btree (field_60);


--
-- Name: database_table_8_last_modified_by_id_66922f26; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_8_last_modified_by_id_66922f26 ON public.database_table_8 USING btree (last_modified_by_id);


--
-- Name: database_table_8_trashed_9f75713b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_8_trashed_9f75713b ON public.database_table_8 USING btree (trashed);


--
-- Name: database_table_9_created_by_id_5fdf2126; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_9_created_by_id_5fdf2126 ON public.database_table_9 USING btree (created_by_id);


--
-- Name: database_table_9_last_modified_by_id_f7a88ce2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_9_last_modified_by_id_f7a88ce2 ON public.database_table_9 USING btree (last_modified_by_id);


--
-- Name: database_table_9_trashed_301db388; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_9_trashed_301db388 ON public.database_table_9 USING btree (trashed);


--
-- Name: database_table_database_id_94b826f0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_database_id_94b826f0 ON public.database_table USING btree (database_id);


--
-- Name: database_table_trashed_12e2391e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_table_trashed_12e2391e ON public.database_table USING btree (trashed);


--
-- Name: database_tableusageupdate_table_id_6a388b33; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tableusageupdate_table_id_6a388b33 ON public.database_tableusageupdate USING btree (table_id);


--
-- Name: database_tablewebhook_table_id_bded0cad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tablewebhook_table_id_bded0cad ON public.database_tablewebhook USING btree (table_id);


--
-- Name: database_tablewebhookcall_webhook_id_333e8ad1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tablewebhookcall_webhook_id_333e8ad1 ON public.database_tablewebhookcall USING btree (webhook_id);


--
-- Name: database_tablewebhookevent_fields_field_id_49fa85df; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tablewebhookevent_fields_field_id_49fa85df ON public.database_tablewebhookevent_fields USING btree (field_id);


--
-- Name: database_tablewebhookevent_fields_tablewebhookevent_id_0e4ceb82; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tablewebhookevent_fields_tablewebhookevent_id_0e4ceb82 ON public.database_tablewebhookevent_fields USING btree (tablewebhookevent_id);


--
-- Name: database_tablewebhookevent_views_tablewebhookevent_id_39df6a86; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tablewebhookevent_views_tablewebhookevent_id_39df6a86 ON public.database_tablewebhookevent_views USING btree (tablewebhookevent_id);


--
-- Name: database_tablewebhookevent_views_view_id_cb0adf58; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tablewebhookevent_views_view_id_cb0adf58 ON public.database_tablewebhookevent_views USING btree (view_id);


--
-- Name: database_tablewebhookevent_webhook_id_8fca798d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tablewebhookevent_webhook_id_8fca798d ON public.database_tablewebhookevent USING btree (webhook_id);


--
-- Name: database_tablewebhookheader_webhook_id_a879ecb4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tablewebhookheader_webhook_id_a879ecb4 ON public.database_tablewebhookheader USING btree (webhook_id);


--
-- Name: database_timelineview_end_date_field_id_99df68f6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_timelineview_end_date_field_id_99df68f6 ON public.database_timelineview USING btree (end_date_field_id);


--
-- Name: database_timelineview_start_date_field_id_da708390; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_timelineview_start_date_field_id_da708390 ON public.database_timelineview USING btree (start_date_field_id);


--
-- Name: database_timelineviewfieldoptions_field_id_be312ccc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_timelineviewfieldoptions_field_id_be312ccc ON public.database_timelineviewfieldoptions USING btree (field_id);


--
-- Name: database_timelineviewfieldoptions_timeline_view_id_4840a23c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_timelineviewfieldoptions_timeline_view_id_4840a23c ON public.database_timelineviewfieldoptions USING btree (timeline_view_id);


--
-- Name: database_token_group_id_aa05b151; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_token_group_id_aa05b151 ON public.database_token USING btree (workspace_id);


--
-- Name: database_token_key_50131e44_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_token_key_50131e44_like ON public.database_token USING btree (key varchar_pattern_ops);


--
-- Name: database_token_user_id_09848757; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_token_user_id_09848757 ON public.database_token USING btree (user_id);


--
-- Name: database_tokenpermission_database_id_fcb9f74f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tokenpermission_database_id_fcb9f74f ON public.database_tokenpermission USING btree (database_id);


--
-- Name: database_tokenpermission_table_id_52facb2e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tokenpermission_table_id_52facb2e ON public.database_tokenpermission USING btree (table_id);


--
-- Name: database_tokenpermission_token_id_d06a00dc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tokenpermission_token_id_d06a00dc ON public.database_tokenpermission USING btree (token_id);


--
-- Name: database_tokenpermission_type_6c9539dd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tokenpermission_type_6c9539dd ON public.database_tokenpermission USING btree (type);


--
-- Name: database_tokenpermission_type_6c9539dd_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_tokenpermission_type_6c9539dd_like ON public.database_tokenpermission USING btree (type varchar_pattern_ops);


--
-- Name: database_trashedrows_table_id_b0682470; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_trashedrows_table_id_b0682470 ON public.database_trashedrows USING btree (table_id);


--
-- Name: database_view_content_type_id_6bf2b2bf; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_view_content_type_id_6bf2b2bf ON public.database_view USING btree (content_type_id);


--
-- Name: database_view_created_by_id_b036ac75; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_view_created_by_id_b036ac75 ON public.database_view USING btree (created_by_id);


--
-- Name: database_view_public_00377314; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_view_public_00377314 ON public.database_view USING btree (public);


--
-- Name: database_view_slug_c1e18cff_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_view_slug_c1e18cff_like ON public.database_view USING btree (slug varchar_pattern_ops);


--
-- Name: database_view_table_id_aa8270d1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_view_table_id_aa8270d1 ON public.database_view USING btree (table_id);


--
-- Name: database_view_trashed_8fa867c2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_view_trashed_8fa867c2 ON public.database_view USING btree (trashed);


--
-- Name: database_viewdecoration_view_id_b60ac1b2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewdecoration_view_id_b60ac1b2 ON public.database_viewdecoration USING btree (view_id);


--
-- Name: database_viewdefaultvalue_field_id_27a1812e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewdefaultvalue_field_id_27a1812e ON public.database_viewdefaultvalue USING btree (field_id);


--
-- Name: database_viewdefaultvalue_view_id_a16c1406; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewdefaultvalue_view_id_a16c1406 ON public.database_viewdefaultvalue USING btree (view_id);


--
-- Name: database_viewfilter_field_id_5f1868dc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewfilter_field_id_5f1868dc ON public.database_viewfilter USING btree (field_id);


--
-- Name: database_viewfilter_group_id_d611d031; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewfilter_group_id_d611d031 ON public.database_viewfilter USING btree (group_id);


--
-- Name: database_viewfilter_view_id_4a62ccde; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewfilter_view_id_4a62ccde ON public.database_viewfilter USING btree (view_id);


--
-- Name: database_viewfiltergroup_parent_group_id_5a6d8b73; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewfiltergroup_parent_group_id_5a6d8b73 ON public.database_viewfiltergroup USING btree (parent_group_id);


--
-- Name: database_viewfiltergroup_view_id_84806393; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewfiltergroup_view_id_84806393 ON public.database_viewfiltergroup USING btree (view_id);


--
-- Name: database_viewgroupby_field_id_a79fc066; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewgroupby_field_id_a79fc066 ON public.database_viewgroupby USING btree (field_id);


--
-- Name: database_viewgroupby_view_id_24658e5d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewgroupby_view_id_24658e5d ON public.database_viewgroupby USING btree (view_id);


--
-- Name: database_viewsort_field_id_e51d1ca2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewsort_field_id_e51d1ca2 ON public.database_viewsort USING btree (field_id);


--
-- Name: database_viewsort_view_id_2e9d197f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewsort_view_id_2e9d197f ON public.database_viewsort USING btree (view_id);


--
-- Name: database_viewsubscription_subscriber_content_type_id_780900e9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewsubscription_subscriber_content_type_id_780900e9 ON public.database_viewsubscription USING btree (subscriber_content_type_id);


--
-- Name: database_viewsubscription_view_id_0ecdfe73; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX database_viewsubscription_view_id_0ecdfe73 ON public.database_viewsubscription USING btree (view_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: integrations_coreperiodicservice_next_run_at_42acedbe; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_coreperiodicservice_next_run_at_42acedbe ON public.integrations_coreperiodicservice USING btree (next_run_at);


--
-- Name: integrations_corerouterserviceedge_service_id_84a34663; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_corerouterserviceedge_service_id_84a34663 ON public.integrations_corerouterserviceedge USING btree (service_id);


--
-- Name: integrations_corestartworkflowservice_workflow_id_ce86e333; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_corestartworkflowservice_workflow_id_ce86e333 ON public.integrations_corestartworkflowservice USING btree (workflow_id);


--
-- Name: integrations_httpformdata_service_id_2c110352; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_httpformdata_service_id_2c110352 ON public.integrations_httpformdata USING btree (service_id);


--
-- Name: integrations_httpheader_service_id_ce8b90dc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_httpheader_service_id_ce8b90dc ON public.integrations_httpheader USING btree (service_id);


--
-- Name: integrations_httpqueryparam_service_id_da61613b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_httpqueryparam_service_id_da61613b ON public.integrations_httpqueryparam USING btree (service_id);


--
-- Name: integrations_localbaserowaggregaterows_field_id_16983939; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowaggregaterows_field_id_16983939 ON public.integrations_localbaserowaggregaterows USING btree (field_id);


--
-- Name: integrations_localbaserowaggregaterows_table_id_57c8661c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowaggregaterows_table_id_57c8661c ON public.integrations_localbaserowaggregaterows USING btree (table_id);


--
-- Name: integrations_localbaserowaggregaterows_view_id_47ec4d91; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowaggregaterows_view_id_47ec4d91 ON public.integrations_localbaserowaggregaterows USING btree (view_id);


--
-- Name: integrations_localbaserowcreaterows_table_id_1b0874e7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowcreaterows_table_id_1b0874e7 ON public.integrations_localbaserowcreaterows USING btree (table_id);


--
-- Name: integrations_localbaserowdeleterow_table_id_a8d1e413; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowdeleterow_table_id_a8d1e413 ON public.integrations_localbaserowdeleterow USING btree (table_id);


--
-- Name: integrations_localbaserowf_localbaserowfieldsupdated__d9f7bc69; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowf_localbaserowfieldsupdated__d9f7bc69 ON public.integrations_localbaserowfieldsupdated_fields USING btree (localbaserowfieldsupdated_id);


--
-- Name: integrations_localbaserowfieldsupdated_fields_field_id_92ac24c6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowfieldsupdated_fields_field_id_92ac24c6 ON public.integrations_localbaserowfieldsupdated_fields USING btree (field_id);


--
-- Name: integrations_localbaserowfieldsupdated_table_id_c2a807c4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowfieldsupdated_table_id_c2a807c4 ON public.integrations_localbaserowfieldsupdated USING btree (table_id);


--
-- Name: integrations_localbaserowgetrow_table_id_f0a221b2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowgetrow_table_id_f0a221b2 ON public.integrations_localbaserowgetrow USING btree (table_id);


--
-- Name: integrations_localbaserowgetrow_view_id_bb09abe6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowgetrow_view_id_bb09abe6 ON public.integrations_localbaserowgetrow USING btree (view_id);


--
-- Name: integrations_localbaserowi_authorized_user_id_8dd67891; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowi_authorized_user_id_8dd67891 ON public.integrations_localbaserowintegration USING btree (authorized_user_id);


--
-- Name: integrations_localbaserowlistrows_table_id_21a3492c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowlistrows_table_id_21a3492c ON public.integrations_localbaserowlistrows USING btree (table_id);


--
-- Name: integrations_localbaserowlistrows_view_id_439c037e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowlistrows_view_id_439c037e ON public.integrations_localbaserowlistrows USING btree (view_id);


--
-- Name: integrations_localbaserowrowcreated_table_id_97301d6a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowrowcreated_table_id_97301d6a ON public.integrations_localbaserowrowscreated USING btree (table_id);


--
-- Name: integrations_localbaserowrowsdeleted_table_id_91fd1fbc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowrowsdeleted_table_id_91fd1fbc ON public.integrations_localbaserowrowsdeleted USING btree (table_id);


--
-- Name: integrations_localbaserowrowupdated_table_id_02483e2b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowrowupdated_table_id_02483e2b ON public.integrations_localbaserowrowsupdated USING btree (table_id);


--
-- Name: integrations_localbaserowt_field_id_1f7d5505; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowt_field_id_1f7d5505 ON public.integrations_localbaserowtableservicefieldmapping USING btree (field_id);


--
-- Name: integrations_localbaserowt_service_id_df624c41; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowt_service_id_df624c41 ON public.integrations_localbaserowtableservicefieldmapping USING btree (service_id);


--
-- Name: integrations_localbaserowtableservicefilter_field_id_53e82940; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowtableservicefilter_field_id_53e82940 ON public.integrations_localbaserowtableservicefilter USING btree (field_id);


--
-- Name: integrations_localbaserowtableservicefilter_service_id_51c2e8fa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowtableservicefilter_service_id_51c2e8fa ON public.integrations_localbaserowtableservicefilter USING btree (service_id);


--
-- Name: integrations_localbaserowtableservicesort_field_id_f9dff360; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowtableservicesort_field_id_f9dff360 ON public.integrations_localbaserowtableservicesort USING btree (field_id);


--
-- Name: integrations_localbaserowtableservicesort_service_id_d63d5b4c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowtableservicesort_service_id_d63d5b4c ON public.integrations_localbaserowtableservicesort USING btree (service_id);


--
-- Name: integrations_localbaserowupdaterows_table_id_7350e0ec; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowupdaterows_table_id_7350e0ec ON public.integrations_localbaserowupdaterows USING btree (table_id);


--
-- Name: integrations_localbaserowupsertrow_table_id_c9f8d243; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_localbaserowupsertrow_table_id_c9f8d243 ON public.integrations_localbaserowupsertrow USING btree (table_id);


--
-- Name: notification_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notification_data ON public.core_notification USING gin (data);


--
-- Name: pendingsearchvaluedeletion_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pendingsearchvaluedeletion_idx ON public.database_pendingsearchvalueupdate USING btree (deletion_workspace_id, field_id, row_id) WHERE (deletion_workspace_id IS NOT NULL);


--
-- Name: pendingsearchvaluedeletion_ord; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pendingsearchvaluedeletion_ord ON public.database_pendingsearchvalueupdate USING btree (updated_on DESC);


--
-- Name: tbl_order_id_1_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tbl_order_id_1_idx ON public.database_table_1 USING btree ("order", id);


--
-- Name: tbl_order_id_2_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tbl_order_id_2_idx ON public.database_table_2 USING btree ("order", id);


--
-- Name: tbl_order_id_3_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tbl_order_id_3_idx ON public.database_table_3 USING btree ("order", id);


--
-- Name: tbl_order_id_4_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tbl_order_id_4_idx ON public.database_table_4 USING btree ("order", id);


--
-- Name: tbl_order_id_5_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tbl_order_id_5_idx ON public.database_table_5 USING btree ("order", id);


--
-- Name: tbl_order_id_6_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tbl_order_id_6_idx ON public.database_table_6 USING btree ("order", id);


--
-- Name: tbl_order_id_7_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tbl_order_id_7_idx ON public.database_table_7 USING btree ("order", id);


--
-- Name: tbl_order_id_8_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tbl_order_id_8_idx ON public.database_table_8 USING btree ("order", id);


--
-- Name: tbl_order_id_9_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tbl_order_id_9_idx ON public.database_table_9 USING btree ("order", id);


--
-- Name: totp_usedcode_user_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX totp_usedcode_user_code_idx ON public.core_totpusedcode USING btree (user_id, code);


--
-- Name: unique_without_parent_trash_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_without_parent_trash_item_id ON public.core_trashentry USING btree (trash_item_type, trash_item_id) WHERE (parent_trash_item_id IS NULL);


--
-- Name: unread_notif_count_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX unread_notif_count_idx ON public.core_notificationrecipient USING btree (broadcast, cleared, read, queued, recipient_id, workspace_id) INCLUDE (notification_id) WHERE ((NOT cleared) AND (NOT read));


--
-- Name: wa_hist_started_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX wa_hist_started_idx ON public.automation_automationworkflowhistory USING btree (workflow_id, started_on DESC);


--
-- Name: wa_hist_status_started_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX wa_hist_status_started_idx ON public.automation_automationworkflowhistory USING btree (workflow_id, status, started_on DESC);


--
-- Name: ws_realtime_channel_group_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ws_realtime_channel_group_idx ON public.ws_realtime_events USING btree (channel_group, id);


--
-- Name: ws_realtime_payload_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ws_realtime_payload_gin_idx ON public.ws_realtime_events USING gin (payload jsonb_path_ops);


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_aiagentactionnode automation_aiagentac_automationnode_ptr_i_e1c87d2e_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_aiagentactionnode
    ADD CONSTRAINT automation_aiagentac_automationnode_ptr_i_e1c87d2e_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automation automation_automatio_application_ptr_id_bea18671_fk_core_appl; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automation
    ADD CONSTRAINT automation_automatio_application_ptr_id_bea18671_fk_core_appl FOREIGN KEY (application_ptr_id) REFERENCES public.core_application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationworkflow automation_automatio_automation_id_ba6f1dbe_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationworkflow
    ADD CONSTRAINT automation_automatio_automation_id_ba6f1dbe_fk_automatio FOREIGN KEY (automation_id) REFERENCES public.automation_automation(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationworkflow_notification_recipients automation_automatio_automationworkflow_i_fb1c0706_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationworkflow_notification_recipients
    ADD CONSTRAINT automation_automatio_automationworkflow_i_fb1c0706_fk_automatio FOREIGN KEY (automationworkflow_id) REFERENCES public.automation_automationworkflow(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationnode automation_automatio_content_type_id_fd0edfc5_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationnode
    ADD CONSTRAINT automation_automatio_content_type_id_fd0edfc5_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationnoderesult automation_automatio_node_history_id_a456f542_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationnoderesult
    ADD CONSTRAINT automation_automatio_node_history_id_a456f542_fk_automatio FOREIGN KEY (node_history_id) REFERENCES public.automation_automationnodehistory(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationnodehistory automation_automatio_node_id_8af8495d_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationnodehistory
    ADD CONSTRAINT automation_automatio_node_id_8af8495d_fk_automatio FOREIGN KEY (node_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationworkflowhistory automation_automatio_original_workflow_id_edf62aa0_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationworkflowhistory
    ADD CONSTRAINT automation_automatio_original_workflow_id_edf62aa0_fk_automatio FOREIGN KEY (original_workflow_id) REFERENCES public.automation_automationworkflow(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automation automation_automatio_published_from_id_d6b4fa07_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automation
    ADD CONSTRAINT automation_automatio_published_from_id_d6b4fa07_fk_automatio FOREIGN KEY (published_from_id) REFERENCES public.automation_automationworkflow(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationnode automation_automatio_service_id_49d4b62d_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationnode
    ADD CONSTRAINT automation_automatio_service_id_49d4b62d_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationworkflowhistory automation_automatio_simulate_until_node__19b153cb_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationworkflowhistory
    ADD CONSTRAINT automation_automatio_simulate_until_node__19b153cb_fk_automatio FOREIGN KEY (simulate_until_node_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationworkflow automation_automatio_simulate_until_node__8cd80a3c_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationworkflow
    ADD CONSTRAINT automation_automatio_simulate_until_node__8cd80a3c_fk_automatio FOREIGN KEY (simulate_until_node_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationworkflow_notification_recipients automation_automatio_user_id_c8d41f0d_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationworkflow_notification_recipients
    ADD CONSTRAINT automation_automatio_user_id_c8d41f0d_fk_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationnodehistory automation_automatio_workflow_history_id_238f30d1_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationnodehistory
    ADD CONSTRAINT automation_automatio_workflow_history_id_238f30d1_fk_automatio FOREIGN KEY (workflow_history_id) REFERENCES public.automation_automationworkflowhistory(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationnode automation_automatio_workflow_id_21b932ab_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationnode
    ADD CONSTRAINT automation_automatio_workflow_id_21b932ab_fk_automatio FOREIGN KEY (workflow_id) REFERENCES public.automation_automationworkflow(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_automationworkflowhistory automation_automatio_workflow_id_7c83997b_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_automationworkflowhistory
    ADD CONSTRAINT automation_automatio_workflow_id_7c83997b_fk_automatio FOREIGN KEY (workflow_id) REFERENCES public.automation_automationworkflow(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_corecsvfilereaderactionnode automation_corecsvfi_automationnode_ptr_i_1fa4fbc4_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_corecsvfilereaderactionnode
    ADD CONSTRAINT automation_corecsvfi_automationnode_ptr_i_1fa4fbc4_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_corehttprequestactionnode automation_corehttpr_automationnode_ptr_i_2448d09b_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_corehttprequestactionnode
    ADD CONSTRAINT automation_corehttpr_automationnode_ptr_i_2448d09b_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_corehttptriggernode automation_corehttpt_automationnode_ptr_i_2696f41e_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_corehttptriggernode
    ADD CONSTRAINT automation_corehttpt_automationnode_ptr_i_2696f41e_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_coreiteratoractionnode automation_coreitera_automationnode_ptr_i_9d004fd2_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_coreiteratoractionnode
    ADD CONSTRAINT automation_coreitera_automationnode_ptr_i_9d004fd2_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_coremanualtriggernode automation_coremanua_automationnode_ptr_i_f2fee880_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_coremanualtriggernode
    ADD CONSTRAINT automation_coremanua_automationnode_ptr_i_f2fee880_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_coreperiodictriggernode automation_coreperio_automationnode_ptr_i_d4b71738_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_coreperiodictriggernode
    ADD CONSTRAINT automation_coreperio_automationnode_ptr_i_d4b71738_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_corerouteractionnode automation_coreroute_automationnode_ptr_i_58a01116_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_corerouteractionnode
    ADD CONSTRAINT automation_coreroute_automationnode_ptr_i_58a01116_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_coresmtpemailactionnode automation_coresmtpe_automationnode_ptr_i_adc9a063_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_coresmtpemailactionnode
    ADD CONSTRAINT automation_coresmtpe_automationnode_ptr_i_adc9a063_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_corestartworkflowactionnode automation_corestart_automationnode_ptr_i_e77c5a95_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_corestartworkflowactionnode
    ADD CONSTRAINT automation_corestart_automationnode_ptr_i_e77c5a95_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_duplicateautomationworkflowjob automation_duplicate_duplicated_automatio_9d00ab50_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_duplicateautomationworkflowjob
    ADD CONSTRAINT automation_duplicate_duplicated_automatio_9d00ab50_fk_automatio FOREIGN KEY (duplicated_automation_workflow_id) REFERENCES public.automation_automationworkflow(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_duplicateautomationworkflowjob automation_duplicate_job_ptr_id_a228370c_fk_core_job_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_duplicateautomationworkflowjob
    ADD CONSTRAINT automation_duplicate_job_ptr_id_a228370c_fk_core_job_ FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_duplicateautomationworkflowjob automation_duplicate_original_automation__0df8d772_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_duplicateautomationworkflowjob
    ADD CONSTRAINT automation_duplicate_original_automation__0df8d772_fk_automatio FOREIGN KEY (original_automation_workflow_id) REFERENCES public.automation_automationworkflow(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowupdaterowsactionnode automation_localbase_automationnode_ptr_i_03439aac_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowupdaterowsactionnode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_03439aac_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowaggregaterowsactionnode automation_localbase_automationnode_ptr_i_1018bb7e_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowaggregaterowsactionnode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_1018bb7e_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowrowscreatedtriggernode automation_localbase_automationnode_ptr_i_17ce9282_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowrowscreatedtriggernode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_17ce9282_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowlistrowsactionnode automation_localbase_automationnode_ptr_i_31827dcd_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowlistrowsactionnode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_31827dcd_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowupdaterowactionnode automation_localbase_automationnode_ptr_i_354f35dc_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowupdaterowactionnode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_354f35dc_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowrowsupdatedtriggernode automation_localbase_automationnode_ptr_i_52e4917e_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowrowsupdatedtriggernode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_52e4917e_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowgetrowactionnode automation_localbase_automationnode_ptr_i_69b98fb6_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowgetrowactionnode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_69b98fb6_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowcreaterowactionnode automation_localbase_automationnode_ptr_i_a92e50a2_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowcreaterowactionnode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_a92e50a2_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowfieldsupdatedtriggernode automation_localbase_automationnode_ptr_i_d9448573_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowfieldsupdatedtriggernode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_d9448573_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowrowsdeletedtriggernode automation_localbase_automationnode_ptr_i_ea27504c_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowrowsdeletedtriggernode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_ea27504c_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowdeleterowactionnode automation_localbase_automationnode_ptr_i_f2a34b43_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowdeleterowactionnode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_f2a34b43_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_localbaserowcreaterowsactionnode automation_localbase_automationnode_ptr_i_f4c8c599_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_localbaserowcreaterowsactionnode
    ADD CONSTRAINT automation_localbase_automationnode_ptr_i_f4c8c599_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_publishautomationworkflowjob automation_publishau_automation_workflow__75834efa_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_publishautomationworkflowjob
    ADD CONSTRAINT automation_publishau_automation_workflow__75834efa_fk_automatio FOREIGN KEY (automation_workflow_id) REFERENCES public.automation_automationworkflow(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_publishautomationworkflowjob automation_publishau_job_ptr_id_20c6360e_fk_core_job_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_publishautomationworkflowjob
    ADD CONSTRAINT automation_publishau_job_ptr_id_20c6360e_fk_core_job_ FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: automation_slackwritemessageactionnode automation_slackwrit_automationnode_ptr_i_18aff886_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.automation_slackwritemessageactionnode
    ADD CONSTRAINT automation_slackwrit_automationnode_ptr_i_18aff886_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_assistantchatprediction baserow_enterprise_a_ai_response_id_67730bb6_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_assistantchatprediction
    ADD CONSTRAINT baserow_enterprise_a_ai_response_id_67730bb6_fk_baserow_e FOREIGN KEY (ai_response_id) REFERENCES public.baserow_enterprise_assistantchatmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_assistantchatmessage baserow_enterprise_a_chat_id_53c3c94c_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_assistantchatmessage
    ADD CONSTRAINT baserow_enterprise_a_chat_id_53c3c94c_fk_baserow_e FOREIGN KEY (chat_id) REFERENCES public.baserow_enterprise_assistantchat(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_authformelement baserow_enterprise_a_element_ptr_id_96b2333b_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_authformelement
    ADD CONSTRAINT baserow_enterprise_a_element_ptr_id_96b2333b_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_assistantchatprediction baserow_enterprise_a_human_message_id_e91c0236_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_assistantchatprediction
    ADD CONSTRAINT baserow_enterprise_a_human_message_id_e91c0236_fk_baserow_e FOREIGN KEY (human_message_id) REFERENCES public.baserow_enterprise_assistantchatmessage(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_auditlogexportjob baserow_enterprise_a_job_ptr_id_ccddc438_fk_core_job_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_auditlogexportjob
    ADD CONSTRAINT baserow_enterprise_a_job_ptr_id_ccddc438_fk_core_job_ FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_assistantchat baserow_enterprise_a_user_id_b443a0fa_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_assistantchat
    ADD CONSTRAINT baserow_enterprise_a_user_id_b443a0fa_fk_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_authformelement baserow_enterprise_a_user_source_id_9f624b86_fk_core_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_authformelement
    ADD CONSTRAINT baserow_enterprise_a_user_source_id_9f624b86_fk_core_user FOREIGN KEY (user_source_id) REFERENCES public.core_usersource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_assistantchat baserow_enterprise_a_workspace_id_8783706d_fk_core_work; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_assistantchat
    ADD CONSTRAINT baserow_enterprise_a_workspace_id_8783706d_fk_core_work FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_buildercustomcode baserow_enterprise_b_builder_id_20e76736_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_buildercustomcode
    ADD CONSTRAINT baserow_enterprise_b_builder_id_20e76736_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_buildercustomscript baserow_enterprise_b_builder_id_3d974bcf_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_buildercustomscript
    ADD CONSTRAINT baserow_enterprise_b_builder_id_3d974bcf_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_corecodeactionnode baserow_enterprise_c_automationnode_ptr_i_0fad3146_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corecodeactionnode
    ADD CONSTRAINT baserow_enterprise_c_automationnode_ptr_i_0fad3146_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_corexlsfilereaderactionnode baserow_enterprise_c_automationnode_ptr_i_ef3f8683_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corexlsfilereaderactionnode
    ADD CONSTRAINT baserow_enterprise_c_automationnode_ptr_i_ef3f8683_fk_automatio FOREIGN KEY (automationnode_ptr_id) REFERENCES public.automation_automationnode(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_corecodeworkflowaction baserow_enterprise_c_builderworkflowactio_38af0b0f_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corecodeworkflowaction
    ADD CONSTRAINT baserow_enterprise_c_builderworkflowactio_38af0b0f_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_corexlsfilereaderworkflowaction baserow_enterprise_c_builderworkflowactio_5165d6b8_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corexlsfilereaderworkflowaction
    ADD CONSTRAINT baserow_enterprise_c_builderworkflowactio_5165d6b8_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_chartwidget baserow_enterprise_c_data_source_id_be88e5fb_fk_dashboard; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_chartwidget
    ADD CONSTRAINT baserow_enterprise_c_data_source_id_be88e5fb_fk_dashboard FOREIGN KEY (data_source_id) REFERENCES public.dashboard_dashboarddatasource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_corexlsfilereaderworkflowaction baserow_enterprise_c_service_id_5e05fb3a_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corexlsfilereaderworkflowaction
    ADD CONSTRAINT baserow_enterprise_c_service_id_5e05fb3a_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_corecodeworkflowaction baserow_enterprise_c_service_id_ae419f30_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corecodeworkflowaction
    ADD CONSTRAINT baserow_enterprise_c_service_id_ae419f30_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_corecodeserviceinjection baserow_enterprise_c_service_id_de9af8c4_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corecodeserviceinjection
    ADD CONSTRAINT baserow_enterprise_c_service_id_de9af8c4_fk_baserow_e FOREIGN KEY (service_id) REFERENCES public.baserow_enterprise_corecodeservice(service_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_corexlsfilereaderservice baserow_enterprise_c_service_ptr_id_31585999_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corexlsfilereaderservice
    ADD CONSTRAINT baserow_enterprise_c_service_ptr_id_31585999_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_corecodeservice baserow_enterprise_c_service_ptr_id_4df38684_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_corecodeservice
    ADD CONSTRAINT baserow_enterprise_c_service_ptr_id_4df38684_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_chartwidget baserow_enterprise_c_widget_ptr_id_da891672_fk_dashboard; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_chartwidget
    ADD CONSTRAINT baserow_enterprise_c_widget_ptr_id_da891672_fk_dashboard FOREIGN KEY (widget_ptr_id) REFERENCES public.dashboard_widget(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datascan baserow_enterprise_d_created_by_id_4248af70_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascan
    ADD CONSTRAINT baserow_enterprise_d_created_by_id_4248af70_fk_auth_user FOREIGN KEY (created_by_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datascan_workspaces baserow_enterprise_d_datascan_id_0e9975cb_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascan_workspaces
    ADD CONSTRAINT baserow_enterprise_d_datascan_id_0e9975cb_fk_baserow_e FOREIGN KEY (datascan_id) REFERENCES public.baserow_enterprise_datascan(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datedependency baserow_enterprise_d_dependency_linkrow_f_ba4a26d1_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datedependency
    ADD CONSTRAINT baserow_enterprise_d_dependency_linkrow_f_ba4a26d1_fk_database_ FOREIGN KEY (dependency_linkrow_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datedependency baserow_enterprise_d_duration_field_id_b8dfe787_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datedependency
    ADD CONSTRAINT baserow_enterprise_d_duration_field_id_b8dfe787_fk_database_ FOREIGN KEY (duration_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datedependency baserow_enterprise_d_end_date_field_id_ae9d3818_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datedependency
    ADD CONSTRAINT baserow_enterprise_d_end_date_field_id_ae9d3818_fk_database_ FOREIGN KEY (end_date_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datascanresult baserow_enterprise_d_field_id_615d75b1_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascanresult
    ADD CONSTRAINT baserow_enterprise_d_field_id_615d75b1_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datedependency baserow_enterprise_d_fieldrule_ptr_id_55dcabb6_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datedependency
    ADD CONSTRAINT baserow_enterprise_d_fieldrule_ptr_id_55dcabb6_fk_database_ FOREIGN KEY (fieldrule_ptr_id) REFERENCES public.database_fieldrule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datascanresultexportjob baserow_enterprise_d_job_ptr_id_4edec262_fk_core_job_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascanresultexportjob
    ADD CONSTRAINT baserow_enterprise_d_job_ptr_id_4edec262_fk_core_job_ FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datascanresult baserow_enterprise_d_scan_id_570da9b4_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascanresult
    ADD CONSTRAINT baserow_enterprise_d_scan_id_570da9b4_fk_baserow_e FOREIGN KEY (scan_id) REFERENCES public.baserow_enterprise_datascan(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datascanlistitem baserow_enterprise_d_scan_id_7308d9e9_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascanlistitem
    ADD CONSTRAINT baserow_enterprise_d_scan_id_7308d9e9_fk_baserow_e FOREIGN KEY (scan_id) REFERENCES public.baserow_enterprise_datascan(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datascan baserow_enterprise_d_source_field_id_65f8d90c_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascan
    ADD CONSTRAINT baserow_enterprise_d_source_field_id_65f8d90c_fk_database_ FOREIGN KEY (source_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datascan baserow_enterprise_d_source_table_id_ec7b7e89_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascan
    ADD CONSTRAINT baserow_enterprise_d_source_table_id_ec7b7e89_fk_database_ FOREIGN KEY (source_table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datedependency baserow_enterprise_d_start_date_field_id_1d2f95f8_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datedependency
    ADD CONSTRAINT baserow_enterprise_d_start_date_field_id_1d2f95f8_fk_database_ FOREIGN KEY (start_date_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datascanresult baserow_enterprise_d_table_id_700dd2d7_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascanresult
    ADD CONSTRAINT baserow_enterprise_d_table_id_700dd2d7_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_datascan_workspaces baserow_enterprise_d_workspace_id_d0b3400b_fk_core_work; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_datascan_workspaces
    ADD CONSTRAINT baserow_enterprise_d_workspace_id_d0b3400b_fk_core_work FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_facebookauthprovidermodel baserow_enterprise_f_authprovidermodel_pt_409119a3_fk_core_auth; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_facebookauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_f_authprovidermodel_pt_409119a3_fk_core_auth FOREIGN KEY (authprovidermodel_ptr_id) REFERENCES public.core_authprovidermodel(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_fileinputelement baserow_enterprise_f_element_ptr_id_4cf1fd47_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_fileinputelement
    ADD CONSTRAINT baserow_enterprise_f_element_ptr_id_4cf1fd47_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_fieldpermissions baserow_enterprise_f_field_id_44e8b371_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_fieldpermissions
    ADD CONSTRAINT baserow_enterprise_f_field_id_44e8b371_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_githubauthprovidermodel baserow_enterprise_g_authprovidermodel_pt_9b6f806d_fk_core_auth; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_githubauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_g_authprovidermodel_pt_9b6f806d_fk_core_auth FOREIGN KEY (authprovidermodel_ptr_id) REFERENCES public.core_authprovidermodel(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_gitlabauthprovidermodel baserow_enterprise_g_authprovidermodel_pt_e81cc5ab_fk_core_auth; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_gitlabauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_g_authprovidermodel_pt_e81cc5ab_fk_core_auth FOREIGN KEY (authprovidermodel_ptr_id) REFERENCES public.core_authprovidermodel(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_googleauthprovidermodel baserow_enterprise_g_authprovidermodel_pt_f235df8e_fk_core_auth; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_googleauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_g_authprovidermodel_pt_f235df8e_fk_core_auth FOREIGN KEY (authprovidermodel_ptr_id) REFERENCES public.core_authprovidermodel(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_gitlabissuesdatasync baserow_enterprise_g_datasync_ptr_id_0009e322_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_gitlabissuesdatasync
    ADD CONSTRAINT baserow_enterprise_g_datasync_ptr_id_0009e322_fk_database_ FOREIGN KEY (datasync_ptr_id) REFERENCES public.database_datasync(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_githubissuesdatasync baserow_enterprise_g_datasync_ptr_id_836e087c_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_githubissuesdatasync
    ADD CONSTRAINT baserow_enterprise_g_datasync_ptr_id_836e087c_fk_database_ FOREIGN KEY (datasync_ptr_id) REFERENCES public.database_datasync(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_hubspotcontactsdatasync baserow_enterprise_h_datasync_ptr_id_5c8ffa43_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_hubspotcontactsdatasync
    ADD CONSTRAINT baserow_enterprise_h_datasync_ptr_id_5c8ffa43_fk_database_ FOREIGN KEY (datasync_ptr_id) REFERENCES public.database_datasync(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_jiraissuesdatasync baserow_enterprise_j_datasync_ptr_id_542dd439_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_jiraissuesdatasync
    ADD CONSTRAINT baserow_enterprise_j_datasync_ptr_id_542dd439_fk_database_ FOREIGN KEY (datasync_ptr_id) REFERENCES public.database_datasync(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_knowledgebasedocument baserow_enterprise_k_category_id_66c5bd32_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_knowledgebasedocument
    ADD CONSTRAINT baserow_enterprise_k_category_id_66c5bd32_fk_baserow_e FOREIGN KEY (category_id) REFERENCES public.baserow_enterprise_knowledgebasecategory(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_knowledgebasecategory baserow_enterprise_k_parent_id_a2ab88f8_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_knowledgebasecategory
    ADD CONSTRAINT baserow_enterprise_k_parent_id_a2ab88f8_fk_baserow_e FOREIGN KEY (parent_id) REFERENCES public.baserow_enterprise_knowledgebasecategory(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_knowledgebasechunk baserow_enterprise_k_source_document_id_ac49085f_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_knowledgebasechunk
    ADD CONSTRAINT baserow_enterprise_k_source_document_id_ac49085f_fk_baserow_e FOREIGN KEY (source_document_id) REFERENCES public.baserow_enterprise_knowledgebasedocument(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_localbaserowpasswordappauthprovider baserow_enterprise_l_appauthprovider_ptr__fa164285_fk_core_appa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowpasswordappauthprovider
    ADD CONSTRAINT baserow_enterprise_l_appauthprovider_ptr__fa164285_fk_core_appa FOREIGN KEY (appauthprovider_ptr_id) REFERENCES public.core_appauthprovider(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_localbaserowtabledatasync baserow_enterprise_l_authorized_user_id_87a841d7_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowtabledatasync
    ADD CONSTRAINT baserow_enterprise_l_authorized_user_id_87a841d7_fk_auth_user FOREIGN KEY (authorized_user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_localbaserowtabledatasync baserow_enterprise_l_datasync_ptr_id_138c6e78_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowtabledatasync
    ADD CONSTRAINT baserow_enterprise_l_datasync_ptr_id_138c6e78_fk_database_ FOREIGN KEY (datasync_ptr_id) REFERENCES public.database_datasync(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_localbaserowusersource baserow_enterprise_l_email_field_id_5de36c5d_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowusersource
    ADD CONSTRAINT baserow_enterprise_l_email_field_id_5de36c5d_fk_database_ FOREIGN KEY (email_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_localbaserowtableserviceaggregationgroupby baserow_enterprise_l_field_id_54b77d5d_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowtableserviceaggregationgroupby
    ADD CONSTRAINT baserow_enterprise_l_field_id_54b77d5d_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_localbaserowtableserviceaggregationseries baserow_enterprise_l_field_id_6a50ba21_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowtableserviceaggregationseries
    ADD CONSTRAINT baserow_enterprise_l_field_id_6a50ba21_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_localbaserowusersource baserow_enterprise_l_name_field_id_fdbe641d_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowusersource
    ADD CONSTRAINT baserow_enterprise_l_name_field_id_fdbe641d_fk_database_ FOREIGN KEY (name_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_localbaserowpasswordappauthprovider baserow_enterprise_l_password_field_id_96187f0c_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowpasswordappauthprovider
    ADD CONSTRAINT baserow_enterprise_l_password_field_id_96187f0c_fk_database_ FOREIGN KEY (password_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_localbaserowusersource baserow_enterprise_l_role_field_id_b061084a_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowusersource
    ADD CONSTRAINT baserow_enterprise_l_role_field_id_b061084a_fk_database_ FOREIGN KEY (role_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_localbaserowtableserviceaggregationsortby baserow_enterprise_l_service_id_66409e2e_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowtableserviceaggregationsortby
    ADD CONSTRAINT baserow_enterprise_l_service_id_66409e2e_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_localbaserowtableserviceaggregationgroupby baserow_enterprise_l_service_id_c51c6b4e_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowtableserviceaggregationgroupby
    ADD CONSTRAINT baserow_enterprise_l_service_id_c51c6b4e_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_localbaserowtableserviceaggregationseries baserow_enterprise_l_service_id_f57c444d_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowtableserviceaggregationseries
    ADD CONSTRAINT baserow_enterprise_l_service_id_f57c444d_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_localbaserowgroupedaggregaterows baserow_enterprise_l_service_ptr_id_5bb9d047_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowgroupedaggregaterows
    ADD CONSTRAINT baserow_enterprise_l_service_ptr_id_5bb9d047_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_localbaserowtabledatasync baserow_enterprise_l_source_table_id_367c2e8a_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowtabledatasync
    ADD CONSTRAINT baserow_enterprise_l_source_table_id_367c2e8a_fk_database_ FOREIGN KEY (source_table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_localbaserowgroupedaggregaterows baserow_enterprise_l_table_id_5c3a683d_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowgroupedaggregaterows
    ADD CONSTRAINT baserow_enterprise_l_table_id_5c3a683d_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_localbaserowusersource baserow_enterprise_l_table_id_809436f6_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowusersource
    ADD CONSTRAINT baserow_enterprise_l_table_id_809436f6_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_localbaserowusersource baserow_enterprise_l_usersource_ptr_id_3f701439_fk_core_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_localbaserowusersource
    ADD CONSTRAINT baserow_enterprise_l_usersource_ptr_id_3f701439_fk_core_user FOREIGN KEY (usersource_ptr_id) REFERENCES public.core_usersource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_localbaserowgroupedaggregaterows baserow_enterprise_l_view_id_6fd8a457_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_localbaserowgroupedaggregaterows
    ADD CONSTRAINT baserow_enterprise_l_view_id_6fd8a457_fk_database_ FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_openidconnectappauthprovidermodel baserow_enterprise_o_appauthprovider_ptr__e6d90f4d_fk_core_appa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_openidconnectappauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_o_appauthprovider_ptr__e6d90f4d_fk_core_appa FOREIGN KEY (appauthprovider_ptr_id) REFERENCES public.core_appauthprovider(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_openidconnectauthprovidermodel baserow_enterprise_o_authprovidermodel_pt_179e3674_fk_core_auth; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_openidconnectauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_o_authprovidermodel_pt_179e3674_fk_core_auth FOREIGN KEY (authprovidermodel_ptr_id) REFERENCES public.core_authprovidermodel(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_periodicdatasyncinterval baserow_enterprise_p_authorized_user_id_a23b524f_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_periodicdatasyncinterval
    ADD CONSTRAINT baserow_enterprise_p_authorized_user_id_a23b524f_fk_auth_user FOREIGN KEY (authorized_user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_periodicdatasyncinterval baserow_enterprise_p_data_sync_id_eb8998ac_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_periodicdatasyncinterval
    ADD CONSTRAINT baserow_enterprise_p_data_sync_id_eb8998ac_fk_database_ FOREIGN KEY (data_sync_id) REFERENCES public.database_datasync(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_role_operations baserow_enterprise_r_operation_id_58992b0b_fk_core_oper; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_role_operations
    ADD CONSTRAINT baserow_enterprise_r_operation_id_58992b0b_fk_core_oper FOREIGN KEY (operation_id) REFERENCES public.core_operation(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_role_operations baserow_enterprise_r_role_id_46a1ac7b_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_role_operations
    ADD CONSTRAINT baserow_enterprise_r_role_id_46a1ac7b_fk_baserow_e FOREIGN KEY (role_id) REFERENCES public.baserow_enterprise_role(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_roleassignment baserow_enterprise_r_role_id_d591b8d7_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_roleassignment
    ADD CONSTRAINT baserow_enterprise_r_role_id_d591b8d7_fk_baserow_e FOREIGN KEY (role_id) REFERENCES public.baserow_enterprise_role(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_roleassignment baserow_enterprise_r_scope_type_id_6190ffc7_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_roleassignment
    ADD CONSTRAINT baserow_enterprise_r_scope_type_id_6190ffc7_fk_django_co FOREIGN KEY (scope_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_roleassignment baserow_enterprise_r_subject_type_id_70e4e12b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_roleassignment
    ADD CONSTRAINT baserow_enterprise_r_subject_type_id_70e4e12b_fk_django_co FOREIGN KEY (subject_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_role baserow_enterprise_r_workspace_id_4d65612e_fk_core_work; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_role
    ADD CONSTRAINT baserow_enterprise_r_workspace_id_4d65612e_fk_core_work FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_roleassignment baserow_enterprise_r_workspace_id_e109e35a_fk_core_work; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_roleassignment
    ADD CONSTRAINT baserow_enterprise_r_workspace_id_e109e35a_fk_core_work FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_samlappauthprovidermodel baserow_enterprise_s_appauthprovider_ptr__881b0605_fk_core_appa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_samlappauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_s_appauthprovider_ptr__881b0605_fk_core_appa FOREIGN KEY (appauthprovider_ptr_id) REFERENCES public.core_appauthprovider(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_samlauthprovidermodel baserow_enterprise_s_authprovidermodel_pt_98f40923_fk_core_auth; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_samlauthprovidermodel
    ADD CONSTRAINT baserow_enterprise_s_authprovidermodel_pt_98f40923_fk_core_auth FOREIGN KEY (authprovidermodel_ptr_id) REFERENCES public.core_authprovidermodel(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_teamsubject baserow_enterprise_t_subject_type_id_9e21b018_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_teamsubject
    ADD CONSTRAINT baserow_enterprise_t_subject_type_id_9e21b018_fk_django_co FOREIGN KEY (subject_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_teamsubject baserow_enterprise_t_team_id_c1a2a489_fk_baserow_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_teamsubject
    ADD CONSTRAINT baserow_enterprise_t_team_id_c1a2a489_fk_baserow_e FOREIGN KEY (team_id) REFERENCES public.baserow_enterprise_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_enterprise_team baserow_enterprise_t_workspace_id_37c9068f_fk_core_work; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_enterprise_team
    ADD CONSTRAINT baserow_enterprise_t_workspace_id_37c9068f_fk_core_work FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_aifield baserow_premium_aifi_ai_auto_update_user__5f71a313_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_aifield
    ADD CONSTRAINT baserow_premium_aifi_ai_auto_update_user__5f71a313_fk_auth_user FOREIGN KEY (ai_auto_update_user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_aifield baserow_premium_aifi_ai_file_field_id_a16778ea_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_aifield
    ADD CONSTRAINT baserow_premium_aifi_ai_file_field_id_a16778ea_fk_database_ FOREIGN KEY (ai_file_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_aifield baserow_premium_aifi_field_ptr_id_4a3fdb24_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_aifield
    ADD CONSTRAINT baserow_premium_aifi_field_ptr_id_4a3fdb24_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_chartseriesconfig baserow_premium_char_series_id_6ab3cf46_fk_baserow_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_chartseriesconfig
    ADD CONSTRAINT baserow_premium_char_series_id_6ab3cf46_fk_baserow_p FOREIGN KEY (series_id) REFERENCES public.baserow_premium_localbaserowtableserviceaggregationseries(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_chartseriesconfig baserow_premium_char_widget_id_502d850d_fk_baserow_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_chartseriesconfig
    ADD CONSTRAINT baserow_premium_char_widget_id_502d850d_fk_baserow_p FOREIGN KEY (widget_id) REFERENCES public.baserow_premium_chartwidget(widget_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_generateaivaluesjob baserow_premium_gene_field_id_15cc461f_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_generateaivaluesjob
    ADD CONSTRAINT baserow_premium_gene_field_id_15cc461f_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_generateaivaluesjob baserow_premium_gene_job_ptr_id_ee95736b_fk_core_job_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_generateaivaluesjob
    ADD CONSTRAINT baserow_premium_gene_job_ptr_id_ee95736b_fk_core_job_ FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_licenseuser baserow_premium_lice_license_id_a98fcec6_fk_baserow_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_licenseuser
    ADD CONSTRAINT baserow_premium_lice_license_id_a98fcec6_fk_baserow_p FOREIGN KEY (license_id) REFERENCES public.baserow_premium_license(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_licenseuser baserow_premium_licenseuser_user_id_562f4a98_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_licenseuser
    ADD CONSTRAINT baserow_premium_licenseuser_user_id_562f4a98_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_piechartwidget baserow_premium_piec_data_source_id_e30f445d_fk_dashboard; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_piechartwidget
    ADD CONSTRAINT baserow_premium_piec_data_source_id_e30f445d_fk_dashboard FOREIGN KEY (data_source_id) REFERENCES public.dashboard_dashboarddatasource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_piechartseriesconfig baserow_premium_piec_series_id_0271cf93_fk_baserow_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_piechartseriesconfig
    ADD CONSTRAINT baserow_premium_piec_series_id_0271cf93_fk_baserow_p FOREIGN KEY (series_id) REFERENCES public.baserow_premium_localbaserowtableserviceaggregationseries(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_piechartseriesconfig baserow_premium_piec_widget_id_29840303_fk_baserow_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_piechartseriesconfig
    ADD CONSTRAINT baserow_premium_piec_widget_id_29840303_fk_baserow_p FOREIGN KEY (widget_id) REFERENCES public.baserow_premium_piechartwidget(widget_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_piechartwidget baserow_premium_piec_widget_ptr_id_e784b3e1_fk_dashboard; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_piechartwidget
    ADD CONSTRAINT baserow_premium_piec_widget_ptr_id_e784b3e1_fk_dashboard FOREIGN KEY (widget_ptr_id) REFERENCES public.dashboard_widget(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_rowcommentsnotificationmode baserow_premium_rowc_table_id_84cd1b14_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_rowcommentsnotificationmode
    ADD CONSTRAINT baserow_premium_rowc_table_id_84cd1b14_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: baserow_premium_rowcommentsnotificationmode baserow_premium_rowc_user_id_af189acd_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.baserow_premium_rowcommentsnotificationmode
    ADD CONSTRAINT baserow_premium_rowc_user_id_af189acd_fk_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_aiagentworkflowaction builder_aiagentworkf_builderworkflowactio_8fde3eae_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_aiagentworkflowaction
    ADD CONSTRAINT builder_aiagentworkf_builderworkflowactio_8fde3eae_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_aiagentworkflowaction builder_aiagentworkf_service_id_a2968d41_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_aiagentworkflowaction
    ADD CONSTRAINT builder_aiagentworkf_service_id_a2968d41_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_builder builder_builder_application_ptr_id_413235bd_fk_core_appl; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_builder
    ADD CONSTRAINT builder_builder_application_ptr_id_413235bd_fk_core_appl FOREIGN KEY (application_ptr_id) REFERENCES public.core_application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_builder builder_builder_favicon_file_id_d767496c_fk_core_userfile_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_builder
    ADD CONSTRAINT builder_builder_favicon_file_id_d767496c_fk_core_userfile_id FOREIGN KEY (favicon_file_id) REFERENCES public.core_userfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_builder builder_builder_login_page_id_3837d62a_fk_builder_page_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_builder
    ADD CONSTRAINT builder_builder_login_page_id_3837d62a_fk_builder_page_id FOREIGN KEY (login_page_id) REFERENCES public.builder_page(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_builderworkflowaction builder_builderworkf_content_type_id_b148baee_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_builderworkflowaction
    ADD CONSTRAINT builder_builderworkf_content_type_id_b148baee_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_builderworkflowaction builder_builderworkf_element_id_5e4bdf53_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_builderworkflowaction
    ADD CONSTRAINT builder_builderworkf_element_id_5e4bdf53_fk_builder_e FOREIGN KEY (element_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_builderworkflowaction builder_builderworkf_page_id_cd71c70c_fk_builder_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_builderworkflowaction
    ADD CONSTRAINT builder_builderworkf_page_id_cd71c70c_fk_builder_p FOREIGN KEY (page_id) REFERENCES public.builder_page(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_buttonelement builder_buttonelemen_element_ptr_id_91403a56_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_buttonelement
    ADD CONSTRAINT builder_buttonelemen_element_ptr_id_91403a56_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_buttonthemeconfigblock builder_buttonthemec_builder_id_83caf226_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_buttonthemeconfigblock
    ADD CONSTRAINT builder_buttonthemec_builder_id_83caf226_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_checkboxelement builder_checkboxelem_element_ptr_id_3ceaf512_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_checkboxelement
    ADD CONSTRAINT builder_checkboxelem_element_ptr_id_3ceaf512_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_choiceelementoption builder_choiceelemen_choice_id_acd1973f_fk_builder_c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_choiceelementoption
    ADD CONSTRAINT builder_choiceelemen_choice_id_acd1973f_fk_builder_c FOREIGN KEY (choice_id) REFERENCES public.builder_choiceelement(element_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_collectionelementpropertyoptions builder_collectionel_element_id_60a376d2_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_collectionelementpropertyoptions
    ADD CONSTRAINT builder_collectionel_element_id_60a376d2_fk_builder_e FOREIGN KEY (element_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_colorthemeconfigblock builder_colorthemeco_builder_id_60bae34d_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_colorthemeconfigblock
    ADD CONSTRAINT builder_colorthemeco_builder_id_60bae34d_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_columnelement builder_columnelemen_element_ptr_id_d1cbe8b1_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_columnelement
    ADD CONSTRAINT builder_columnelemen_element_ptr_id_d1cbe8b1_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_corecsvfilereaderworkflowaction builder_corecsvfiler_builderworkflowactio_a5d64f7e_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_corecsvfilereaderworkflowaction
    ADD CONSTRAINT builder_corecsvfiler_builderworkflowactio_a5d64f7e_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_corecsvfilereaderworkflowaction builder_corecsvfiler_service_id_cf7c15fc_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_corecsvfilereaderworkflowaction
    ADD CONSTRAINT builder_corecsvfiler_service_id_cf7c15fc_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_corehttprequestworkflowaction builder_corehttprequ_builderworkflowactio_bf2b667f_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_corehttprequestworkflowaction
    ADD CONSTRAINT builder_corehttprequ_builderworkflowactio_bf2b667f_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_corehttprequestworkflowaction builder_corehttprequ_service_id_206cfc6f_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_corehttprequestworkflowaction
    ADD CONSTRAINT builder_corehttprequ_service_id_206cfc6f_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_coresmtpemailworkflowaction builder_coresmtpemai_builderworkflowactio_ea03d168_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_coresmtpemailworkflowaction
    ADD CONSTRAINT builder_coresmtpemai_builderworkflowactio_ea03d168_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_coresmtpemailworkflowaction builder_coresmtpemai_service_id_8d3e84f4_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_coresmtpemailworkflowaction
    ADD CONSTRAINT builder_coresmtpemai_service_id_8d3e84f4_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_corestartworkflowworkflowaction builder_corestartwor_builderworkflowactio_b9db6077_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_corestartworkflowworkflowaction
    ADD CONSTRAINT builder_corestartwor_builderworkflowactio_b9db6077_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_corestartworkflowworkflowaction builder_corestartwor_service_id_7d0127ba_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_corestartworkflowworkflowaction
    ADD CONSTRAINT builder_corestartwor_service_id_7d0127ba_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_customdomain builder_customdomain_domain_ptr_id_e5c837d7_fk_builder_d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_customdomain
    ADD CONSTRAINT builder_customdomain_domain_ptr_id_e5c837d7_fk_builder_d FOREIGN KEY (domain_ptr_id) REFERENCES public.builder_domain(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_datasource builder_datasource_page_id_cec9a398_fk_builder_page_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_datasource
    ADD CONSTRAINT builder_datasource_page_id_cec9a398_fk_builder_page_id FOREIGN KEY (page_id) REFERENCES public.builder_page(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_datasource builder_datasource_service_id_e1965de7_fk_core_service_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_datasource
    ADD CONSTRAINT builder_datasource_service_id_e1965de7_fk_core_service_id FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_datetimepickerelement builder_datetimepick_element_ptr_id_f1309074_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_datetimepickerelement
    ADD CONSTRAINT builder_datetimepick_element_ptr_id_f1309074_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_domain builder_domain_builder_id_dcaa7438_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_domain
    ADD CONSTRAINT builder_domain_builder_id_dcaa7438_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_domain builder_domain_content_type_id_3cc79455_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_domain
    ADD CONSTRAINT builder_domain_content_type_id_3cc79455_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_domain builder_domain_published_to_id_cf629014_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_domain
    ADD CONSTRAINT builder_domain_published_to_id_cf629014_fk_builder_b FOREIGN KEY (published_to_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_choiceelement builder_dropdownelem_element_ptr_id_bda53e0a_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_choiceelement
    ADD CONSTRAINT builder_dropdownelem_element_ptr_id_bda53e0a_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_duplicatepagejob builder_duplicatepag_duplicated_page_id_0e5f7654_fk_builder_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_duplicatepagejob
    ADD CONSTRAINT builder_duplicatepag_duplicated_page_id_0e5f7654_fk_builder_p FOREIGN KEY (duplicated_page_id) REFERENCES public.builder_page(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_duplicatepagejob builder_duplicatepag_original_page_id_de957244_fk_builder_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_duplicatepagejob
    ADD CONSTRAINT builder_duplicatepag_original_page_id_de957244_fk_builder_p FOREIGN KEY (original_page_id) REFERENCES public.builder_page(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_duplicatepagejob builder_duplicatepagejob_job_ptr_id_73b1bf58_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_duplicatepagejob
    ADD CONSTRAINT builder_duplicatepagejob_job_ptr_id_73b1bf58_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_element builder_element_content_type_id_4b196482_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_element
    ADD CONSTRAINT builder_element_content_type_id_4b196482_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_element builder_element_page_id_97ce22ab_fk_builder_page_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_element
    ADD CONSTRAINT builder_element_page_id_97ce22ab_fk_builder_page_id FOREIGN KEY (page_id) REFERENCES public.builder_page(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_element builder_element_parent_element_id_422d0390_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_element
    ADD CONSTRAINT builder_element_parent_element_id_422d0390_fk_builder_e FOREIGN KEY (parent_element_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_element builder_element_style_background_fil_f99b4091_fk_core_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_element
    ADD CONSTRAINT builder_element_style_background_fil_f99b4091_fk_core_user FOREIGN KEY (style_background_file_id) REFERENCES public.core_userfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_footerelement builder_footerelemen_element_ptr_id_042fc3bd_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_footerelement
    ADD CONSTRAINT builder_footerelemen_element_ptr_id_042fc3bd_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_footerelement_pages builder_footerelemen_footerelement_id_41c64a4d_fk_builder_f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_footerelement_pages
    ADD CONSTRAINT builder_footerelemen_footerelement_id_41c64a4d_fk_builder_f FOREIGN KEY (footerelement_id) REFERENCES public.builder_footerelement(element_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_footerelement_pages builder_footerelement_pages_page_id_04cb6ca1_fk_builder_page_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_footerelement_pages
    ADD CONSTRAINT builder_footerelement_pages_page_id_04cb6ca1_fk_builder_page_id FOREIGN KEY (page_id) REFERENCES public.builder_page(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_formcontainerelement builder_formcontaine_element_ptr_id_5a727fae_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_formcontainerelement
    ADD CONSTRAINT builder_formcontaine_element_ptr_id_5a727fae_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_headerelement builder_headerelemen_element_ptr_id_362aced6_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_headerelement
    ADD CONSTRAINT builder_headerelemen_element_ptr_id_362aced6_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_headerelement_pages builder_headerelemen_headerelement_id_251194af_fk_builder_h; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_headerelement_pages
    ADD CONSTRAINT builder_headerelemen_headerelement_id_251194af_fk_builder_h FOREIGN KEY (headerelement_id) REFERENCES public.builder_headerelement(element_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_headerelement_pages builder_headerelement_pages_page_id_e26b6226_fk_builder_page_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_headerelement_pages
    ADD CONSTRAINT builder_headerelement_pages_page_id_e26b6226_fk_builder_page_id FOREIGN KEY (page_id) REFERENCES public.builder_page(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_headingelement builder_headingeleme_element_ptr_id_c573b396_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_headingelement
    ADD CONSTRAINT builder_headingeleme_element_ptr_id_c573b396_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_iframeelement builder_iframeelemen_element_ptr_id_b91a32ec_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_iframeelement
    ADD CONSTRAINT builder_iframeelemen_element_ptr_id_b91a32ec_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_imageelement builder_imageelement_element_ptr_id_8b96578a_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_imageelement
    ADD CONSTRAINT builder_imageelement_element_ptr_id_8b96578a_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_imageelement builder_imageelement_image_file_id_ebab311b_fk_core_userfile_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_imageelement
    ADD CONSTRAINT builder_imageelement_image_file_id_ebab311b_fk_core_userfile_id FOREIGN KEY (image_file_id) REFERENCES public.core_userfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_imagethemeconfigblock builder_imagethemeco_builder_id_3e0cf4bd_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_imagethemeconfigblock
    ADD CONSTRAINT builder_imagethemeco_builder_id_3e0cf4bd_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_inputtextelement builder_inputtextele_element_ptr_id_36f823e7_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_inputtextelement
    ADD CONSTRAINT builder_inputtextele_element_ptr_id_36f823e7_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_inputthemeconfigblock builder_inputthemeco_builder_id_35d09414_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_inputthemeconfigblock
    ADD CONSTRAINT builder_inputthemeco_builder_id_35d09414_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_linkelement builder_linkelement_element_ptr_id_3b6fc425_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_linkelement
    ADD CONSTRAINT builder_linkelement_element_ptr_id_3b6fc425_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_linkelement builder_linkelement_navigate_to_page_id_4002370e_fk_builder_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_linkelement
    ADD CONSTRAINT builder_linkelement_navigate_to_page_id_4002370e_fk_builder_p FOREIGN KEY (navigate_to_page_id) REFERENCES public.builder_page(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_linkthemeconfigblock builder_linkthemecon_builder_id_49077bf8_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_linkthemeconfigblock
    ADD CONSTRAINT builder_linkthemecon_builder_id_49077bf8_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_localbaserowdeleterowworkflowaction builder_localbaserow_builderworkflowactio_24784869_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowdeleterowworkflowaction
    ADD CONSTRAINT builder_localbaserow_builderworkflowactio_24784869_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_localbaserowcreaterowsworkflowaction builder_localbaserow_builderworkflowactio_8a5e237f_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowcreaterowsworkflowaction
    ADD CONSTRAINT builder_localbaserow_builderworkflowactio_8a5e237f_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_localbaserowupdaterowworkflowaction builder_localbaserow_builderworkflowactio_98dc0d74_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowupdaterowworkflowaction
    ADD CONSTRAINT builder_localbaserow_builderworkflowactio_98dc0d74_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_localbaserowupdaterowsworkflowaction builder_localbaserow_builderworkflowactio_e43be43d_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowupdaterowsworkflowaction
    ADD CONSTRAINT builder_localbaserow_builderworkflowactio_e43be43d_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_localbaserowcreaterowworkflowaction builder_localbaserow_builderworkflowactio_fd41ff95_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowcreaterowworkflowaction
    ADD CONSTRAINT builder_localbaserow_builderworkflowactio_fd41ff95_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_localbaserowdeleterowworkflowaction builder_localbaserow_service_id_50d4be5b_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowdeleterowworkflowaction
    ADD CONSTRAINT builder_localbaserow_service_id_50d4be5b_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_localbaserowcreaterowworkflowaction builder_localbaserow_service_id_7e512d51_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowcreaterowworkflowaction
    ADD CONSTRAINT builder_localbaserow_service_id_7e512d51_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_localbaserowupdaterowworkflowaction builder_localbaserow_service_id_bc7906e7_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowupdaterowworkflowaction
    ADD CONSTRAINT builder_localbaserow_service_id_bc7906e7_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_localbaserowcreaterowsworkflowaction builder_localbaserow_service_id_e700e56f_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowcreaterowsworkflowaction
    ADD CONSTRAINT builder_localbaserow_service_id_e700e56f_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_localbaserowupdaterowsworkflowaction builder_localbaserow_service_id_e74eaf8d_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_localbaserowupdaterowsworkflowaction
    ADD CONSTRAINT builder_localbaserow_service_id_e74eaf8d_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_logoutworkflowaction builder_logoutworkfl_builderworkflowactio_b5a26968_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_logoutworkflowaction
    ADD CONSTRAINT builder_logoutworkfl_builderworkflowactio_b5a26968_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_menuelement_menu_items builder_menuelement__menuelement_id_e5b36ce0_fk_builder_m; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_menuelement_menu_items
    ADD CONSTRAINT builder_menuelement__menuelement_id_e5b36ce0_fk_builder_m FOREIGN KEY (menuelement_id) REFERENCES public.builder_menuelement(element_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_menuelement_menu_items builder_menuelement__menuitemelement_id_efaec61d_fk_builder_m; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_menuelement_menu_items
    ADD CONSTRAINT builder_menuelement__menuitemelement_id_efaec61d_fk_builder_m FOREIGN KEY (menuitemelement_id) REFERENCES public.builder_menuitemelement(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_menuelement builder_menuelement_element_ptr_id_fe9eb651_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_menuelement
    ADD CONSTRAINT builder_menuelement_element_ptr_id_fe9eb651_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_menuitemelement builder_menuitemelem_navigate_to_page_id_f4037457_fk_builder_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_menuitemelement
    ADD CONSTRAINT builder_menuitemelem_navigate_to_page_id_f4037457_fk_builder_p FOREIGN KEY (navigate_to_page_id) REFERENCES public.builder_page(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_menuitemelement builder_menuitemelem_parent_menu_item_id_ec829f4b_fk_builder_m; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_menuitemelement
    ADD CONSTRAINT builder_menuitemelem_parent_menu_item_id_ec829f4b_fk_builder_m FOREIGN KEY (parent_menu_item_id) REFERENCES public.builder_menuitemelement(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_notificationworkflowaction builder_notification_builderworkflowactio_39fb6e8c_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_notificationworkflowaction
    ADD CONSTRAINT builder_notification_builderworkflowactio_39fb6e8c_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_openpageworkflowaction builder_openpagework_builderworkflowactio_a57466af_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_openpageworkflowaction
    ADD CONSTRAINT builder_openpagework_builderworkflowactio_a57466af_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_openpageworkflowaction builder_openpagework_navigate_to_page_id_7f0c6c81_fk_builder_p; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_openpageworkflowaction
    ADD CONSTRAINT builder_openpagework_navigate_to_page_id_7f0c6c81_fk_builder_p FOREIGN KEY (navigate_to_page_id) REFERENCES public.builder_page(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_page builder_page_builder_id_b7d24d63_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_page
    ADD CONSTRAINT builder_page_builder_id_b7d24d63_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_pagethemeconfigblock builder_pagethemecon_builder_id_060ac919_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_pagethemeconfigblock
    ADD CONSTRAINT builder_pagethemecon_builder_id_060ac919_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_pagethemeconfigblock builder_pagethemecon_page_background_file_44535b73_fk_core_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_pagethemeconfigblock
    ADD CONSTRAINT builder_pagethemecon_page_background_file_44535b73_fk_core_user FOREIGN KEY (page_background_file_id) REFERENCES public.core_userfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_textelement builder_paragraphele_element_ptr_id_0a20f974_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_textelement
    ADD CONSTRAINT builder_paragraphele_element_ptr_id_0a20f974_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_publishdomainjob builder_publishdomai_domain_id_f81e0d37_fk_builder_d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_publishdomainjob
    ADD CONSTRAINT builder_publishdomai_domain_id_f81e0d37_fk_builder_d FOREIGN KEY (domain_id) REFERENCES public.builder_domain(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_publishdomainjob builder_publishdomainjob_job_ptr_id_9dfa3ca1_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_publishdomainjob
    ADD CONSTRAINT builder_publishdomainjob_job_ptr_id_9dfa3ca1_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_ratingelement builder_ratingelemen_element_ptr_id_0f2e99c3_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_ratingelement
    ADD CONSTRAINT builder_ratingelemen_element_ptr_id_0f2e99c3_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_ratinginputelement builder_ratinginpute_element_ptr_id_2f9f641c_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_ratinginputelement
    ADD CONSTRAINT builder_ratinginpute_element_ptr_id_2f9f641c_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_recordselectorelement builder_recordselect_data_source_id_91fadd6f_fk_builder_d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_recordselectorelement
    ADD CONSTRAINT builder_recordselect_data_source_id_91fadd6f_fk_builder_d FOREIGN KEY (data_source_id) REFERENCES public.builder_datasource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_recordselectorelement builder_recordselect_element_ptr_id_27189157_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_recordselectorelement
    ADD CONSTRAINT builder_recordselect_element_ptr_id_27189157_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_refreshdatasourceworkflowaction builder_refreshdatas_builderworkflowactio_c654ce5d_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_refreshdatasourceworkflowaction
    ADD CONSTRAINT builder_refreshdatas_builderworkflowactio_c654ce5d_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_refreshdatasourceworkflowaction builder_refreshdatas_data_source_id_b4f22517_fk_builder_d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_refreshdatasourceworkflowaction
    ADD CONSTRAINT builder_refreshdatas_data_source_id_b4f22517_fk_builder_d FOREIGN KEY (data_source_id) REFERENCES public.builder_datasource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_repeatelement builder_repeatelemen_data_source_id_3d03270d_fk_builder_d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_repeatelement
    ADD CONSTRAINT builder_repeatelemen_data_source_id_3d03270d_fk_builder_d FOREIGN KEY (data_source_id) REFERENCES public.builder_datasource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_repeatelement builder_repeatelemen_element_ptr_id_77892d00_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_repeatelement
    ADD CONSTRAINT builder_repeatelemen_element_ptr_id_77892d00_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_simplecontainerelement builder_simplecontai_element_ptr_id_7f912926_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_simplecontainerelement
    ADD CONSTRAINT builder_simplecontai_element_ptr_id_7f912926_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_slackwritemessageworkflowaction builder_slackwriteme_builderworkflowactio_0453bcd6_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_slackwritemessageworkflowaction
    ADD CONSTRAINT builder_slackwriteme_builderworkflowactio_0453bcd6_fk_builder_b FOREIGN KEY (builderworkflowaction_ptr_id) REFERENCES public.builder_builderworkflowaction(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_slackwritemessageworkflowaction builder_slackwriteme_service_id_830ca442_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_slackwritemessageworkflowaction
    ADD CONSTRAINT builder_slackwriteme_service_id_830ca442_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_subdomain builder_subdomain_domain_ptr_id_ef8bcead_fk_builder_domain_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_subdomain
    ADD CONSTRAINT builder_subdomain_domain_ptr_id_ef8bcead_fk_builder_domain_id FOREIGN KEY (domain_ptr_id) REFERENCES public.builder_domain(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_tableelement_fields builder_tableelement_collectionfield_id_201f0926_fk_builder_c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_tableelement_fields
    ADD CONSTRAINT builder_tableelement_collectionfield_id_201f0926_fk_builder_c FOREIGN KEY (collectionfield_id) REFERENCES public.builder_collectionfield(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_tableelement builder_tableelement_data_source_id_87426f7d_fk_builder_d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_tableelement
    ADD CONSTRAINT builder_tableelement_data_source_id_87426f7d_fk_builder_d FOREIGN KEY (data_source_id) REFERENCES public.builder_datasource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_tableelement builder_tableelement_element_ptr_id_80da2afd_fk_builder_e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_tableelement
    ADD CONSTRAINT builder_tableelement_element_ptr_id_80da2afd_fk_builder_e FOREIGN KEY (element_ptr_id) REFERENCES public.builder_element(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_tableelement_fields builder_tableelement_tableelement_id_112738d0_fk_builder_t; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_tableelement_fields
    ADD CONSTRAINT builder_tableelement_tableelement_id_112738d0_fk_builder_t FOREIGN KEY (tableelement_id) REFERENCES public.builder_tableelement(element_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_tablethemeconfigblock builder_tablethemeco_builder_id_e0008eed_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_tablethemeconfigblock
    ADD CONSTRAINT builder_tablethemeco_builder_id_e0008eed_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: builder_typographythemeconfigblock builder_typographyth_builder_id_bcfce7ff_fk_builder_b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builder_typographythemeconfigblock
    ADD CONSTRAINT builder_typographyth_builder_id_bcfce7ff_fk_builder_b FOREIGN KEY (builder_id) REFERENCES public.builder_builder(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_action core_action_user_id_eed182ff_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_action
    ADD CONSTRAINT core_action_user_id_eed182ff_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_action core_action_workspace_id_42061eec_fk_core_workspace_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_action
    ADD CONSTRAINT core_action_workspace_id_42061eec_fk_core_workspace_id FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_appauthprovider core_appauthprovider_content_type_id_55bde76e_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_appauthprovider
    ADD CONSTRAINT core_appauthprovider_content_type_id_55bde76e_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_appauthprovider core_appauthprovider_user_source_id_ec8d3566_fk_core_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_appauthprovider
    ADD CONSTRAINT core_appauthprovider_user_source_id_ec8d3566_fk_core_user FOREIGN KEY (user_source_id) REFERENCES public.core_usersource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_application core_application_content_type_id_472cc32f_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_application
    ADD CONSTRAINT core_application_content_type_id_472cc32f_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_application core_application_installed_from_templ_a539253e_fk_core_temp; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_application
    ADD CONSTRAINT core_application_installed_from_templ_a539253e_fk_core_temp FOREIGN KEY (installed_from_template_id) REFERENCES public.core_template(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_application core_application_workspace_id_255a3af3_fk_core_workspace_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_application
    ADD CONSTRAINT core_application_workspace_id_255a3af3_fk_core_workspace_id FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_authprovidermodel_users core_authprovidermod_authprovidermodel_id_932b69eb_fk_core_auth; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_authprovidermodel_users
    ADD CONSTRAINT core_authprovidermod_authprovidermodel_id_932b69eb_fk_core_auth FOREIGN KEY (authprovidermodel_id) REFERENCES public.core_authprovidermodel(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_authprovidermodel core_authprovidermod_content_type_id_a7ec10bb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_authprovidermodel
    ADD CONSTRAINT core_authprovidermod_content_type_id_a7ec10bb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_authprovidermodel_users core_authprovidermodel_users_user_id_0af0c09f_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_authprovidermodel_users
    ADD CONSTRAINT core_authprovidermodel_users_user_id_0af0c09f_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_createsnapshotjob core_createsnapshotjob_job_ptr_id_beedabeb_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_createsnapshotjob
    ADD CONSTRAINT core_createsnapshotjob_job_ptr_id_beedabeb_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_createsnapshotjob core_createsnapshotjob_snapshot_id_994c6005_fk_core_snapshot_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_createsnapshotjob
    ADD CONSTRAINT core_createsnapshotjob_snapshot_id_994c6005_fk_core_snapshot_id FOREIGN KEY (snapshot_id) REFERENCES public.core_snapshot(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_duplicateapplicationjob core_duplicateapplic_duplicated_applicati_3f04f0ea_fk_core_appl; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_duplicateapplicationjob
    ADD CONSTRAINT core_duplicateapplic_duplicated_applicati_3f04f0ea_fk_core_appl FOREIGN KEY (duplicated_application_id) REFERENCES public.core_application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_duplicateapplicationjob core_duplicateapplic_original_application_09218c73_fk_core_appl; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_duplicateapplicationjob
    ADD CONSTRAINT core_duplicateapplic_original_application_09218c73_fk_core_appl FOREIGN KEY (original_application_id) REFERENCES public.core_application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_duplicateapplicationjob core_duplicateapplicationjob_job_ptr_id_3e14c89b_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_duplicateapplicationjob
    ADD CONSTRAINT core_duplicateapplicationjob_job_ptr_id_3e14c89b_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_exportapplicationsjob core_exportapplicati_resource_id_9f185c4d_fk_core_impo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_exportapplicationsjob
    ADD CONSTRAINT core_exportapplicati_resource_id_9f185c4d_fk_core_impo FOREIGN KEY (resource_id) REFERENCES public.core_importexportresource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_exportapplicationsjob core_exportapplicati_workspace_id_8d4c8e7d_fk_core_work; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_exportapplicationsjob
    ADD CONSTRAINT core_exportapplicati_workspace_id_8d4c8e7d_fk_core_work FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_exportapplicationsjob core_exportapplicationsjob_job_ptr_id_ab3231e9_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_exportapplicationsjob
    ADD CONSTRAINT core_exportapplicationsjob_job_ptr_id_ab3231e9_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_workspaceinvitation core_groupinvitation_invited_by_id_ecbae904_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workspaceinvitation
    ADD CONSTRAINT core_groupinvitation_invited_by_id_ecbae904_fk_auth_user_id FOREIGN KEY (invited_by_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_workspaceuser core_groupuser_user_id_3e69dc39_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workspaceuser
    ADD CONSTRAINT core_groupuser_user_id_3e69dc39_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_importapplicationsjob core_importapplicati_resource_id_604c7bda_fk_core_impo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_importapplicationsjob
    ADD CONSTRAINT core_importapplicati_resource_id_604c7bda_fk_core_impo FOREIGN KEY (resource_id) REFERENCES public.core_importexportresource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_importapplicationsjob core_importapplicati_workspace_id_08a8bd7d_fk_core_work; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_importapplicationsjob
    ADD CONSTRAINT core_importapplicati_workspace_id_08a8bd7d_fk_core_work FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_importapplicationsjob core_importapplicationsjob_job_ptr_id_44b7790b_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_importapplicationsjob
    ADD CONSTRAINT core_importapplicationsjob_job_ptr_id_44b7790b_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_importexportresource core_importexportres_created_by_id_37d8fbc4_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_importexportresource
    ADD CONSTRAINT core_importexportres_created_by_id_37d8fbc4_fk_auth_user FOREIGN KEY (created_by_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_installtemplatejob core_installtemplate_template_id_1b0e3630_fk_core_temp; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_installtemplatejob
    ADD CONSTRAINT core_installtemplate_template_id_1b0e3630_fk_core_temp FOREIGN KEY (template_id) REFERENCES public.core_template(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_installtemplatejob core_installtemplate_workspace_id_01fff96d_fk_core_work; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_installtemplatejob
    ADD CONSTRAINT core_installtemplate_workspace_id_01fff96d_fk_core_work FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_installtemplatejob core_installtemplatejob_job_ptr_id_55516759_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_installtemplatejob
    ADD CONSTRAINT core_installtemplatejob_job_ptr_id_55516759_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_integration core_integration_application_id_818d7adb_fk_core_application_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_integration
    ADD CONSTRAINT core_integration_application_id_818d7adb_fk_core_application_id FOREIGN KEY (application_id) REFERENCES public.core_application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_integration core_integration_content_type_id_99657d37_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_integration
    ADD CONSTRAINT core_integration_content_type_id_99657d37_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_job core_job_content_type_id_6aeb9e39_fk_django_content_type_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_job
    ADD CONSTRAINT core_job_content_type_id_6aeb9e39_fk_django_content_type_id FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_job core_job_user_id_b69eefda_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_job
    ADD CONSTRAINT core_job_user_id_b69eefda_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_mcpendpoint core_mcpendpoint_user_id_3ee955c7_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_mcpendpoint
    ADD CONSTRAINT core_mcpendpoint_user_id_3ee955c7_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_mcpendpoint core_mcpendpoint_workspace_id_431218c6_fk_core_workspace_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_mcpendpoint
    ADD CONSTRAINT core_mcpendpoint_workspace_id_431218c6_fk_core_workspace_id FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_notification core_notification_sender_id_7af58206_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_notification
    ADD CONSTRAINT core_notification_sender_id_7af58206_fk_auth_user_id FOREIGN KEY (sender_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_notification core_notification_workspace_id_99158c25_fk_core_workspace_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_notification
    ADD CONSTRAINT core_notification_workspace_id_99158c25_fk_core_workspace_id FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_notificationrecipient core_notificationrec_notification_id_48f0f193_fk_core_noti; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_notificationrecipient
    ADD CONSTRAINT core_notificationrec_notification_id_48f0f193_fk_core_noti FOREIGN KEY (notification_id) REFERENCES public.core_notification(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_notificationrecipient core_notificationrec_recipient_id_cf073056_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_notificationrecipient
    ADD CONSTRAINT core_notificationrec_recipient_id_cf073056_fk_auth_user FOREIGN KEY (recipient_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_passwordauthprovidermodel core_passwordauthpro_authprovidermodel_pt_7f097cc8_fk_core_auth; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_passwordauthprovidermodel
    ADD CONSTRAINT core_passwordauthpro_authprovidermodel_pt_7f097cc8_fk_core_auth FOREIGN KEY (authprovidermodel_ptr_id) REFERENCES public.core_authprovidermodel(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_restoresnapshotjob core_restoresnapshot_snapshot_id_76cd92b9_fk_core_snap; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_restoresnapshotjob
    ADD CONSTRAINT core_restoresnapshot_snapshot_id_76cd92b9_fk_core_snap FOREIGN KEY (snapshot_id) REFERENCES public.core_snapshot(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_restoresnapshotjob core_restoresnapshotjob_job_ptr_id_e8cbceb9_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_restoresnapshotjob
    ADD CONSTRAINT core_restoresnapshotjob_job_ptr_id_e8cbceb9_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_schemaoperation core_schemaoperation_content_type_id_da4058fb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_schemaoperation
    ADD CONSTRAINT core_schemaoperation_content_type_id_da4058fb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_service core_service_content_type_id_a9ea8d7e_fk_django_content_type_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_service
    ADD CONSTRAINT core_service_content_type_id_a9ea8d7e_fk_django_content_type_id FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_service core_service_integration_id_396ff441_fk_core_integration_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_service
    ADD CONSTRAINT core_service_integration_id_396ff441_fk_core_integration_id FOREIGN KEY (integration_id) REFERENCES public.core_integration(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_settings core_settings_co_branding_logo_id_1d9838c7_fk_core_userfile_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_settings
    ADD CONSTRAINT core_settings_co_branding_logo_id_1d9838c7_fk_core_userfile_id FOREIGN KEY (co_branding_logo_id) REFERENCES public.core_userfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_snapshot core_snapshot_created_by_id_6dbd6149_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_snapshot
    ADD CONSTRAINT core_snapshot_created_by_id_6dbd6149_fk_auth_user_id FOREIGN KEY (created_by_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_snapshot core_snapshot_snapshot_from_applic_c2b7fb78_fk_core_appl; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_snapshot
    ADD CONSTRAINT core_snapshot_snapshot_from_applic_c2b7fb78_fk_core_appl FOREIGN KEY (snapshot_from_application_id) REFERENCES public.core_application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_snapshot core_snapshot_snapshot_to_applicat_0ce2529c_fk_core_appl; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_snapshot
    ADD CONSTRAINT core_snapshot_snapshot_to_applicat_0ce2529c_fk_core_appl FOREIGN KEY (snapshot_to_application_id) REFERENCES public.core_application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_template_categories core_template_catego_template_id_2ab2048f_fk_core_temp; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_template_categories
    ADD CONSTRAINT core_template_catego_template_id_2ab2048f_fk_core_temp FOREIGN KEY (template_id) REFERENCES public.core_template(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_template_categories core_template_catego_templatecategory_id_da998bfd_fk_core_temp; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_template_categories
    ADD CONSTRAINT core_template_catego_templatecategory_id_da998bfd_fk_core_temp FOREIGN KEY (templatecategory_id) REFERENCES public.core_templatecategory(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_template core_template_workspace_id_bb88d2b9_fk_core_workspace_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_template
    ADD CONSTRAINT core_template_workspace_id_bb88d2b9_fk_core_workspace_id FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_totpauthprovidermodel core_totpauthprovide_twofactorauthprovide_8120821f_fk_core_twof; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_totpauthprovidermodel
    ADD CONSTRAINT core_totpauthprovide_twofactorauthprovide_8120821f_fk_core_twof FOREIGN KEY (twofactorauthprovidermodel_ptr_id) REFERENCES public.core_twofactorauthprovidermodel(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_totpusedcode core_totpusedcode_user_id_7a35bd2c_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_totpusedcode
    ADD CONSTRAINT core_totpusedcode_user_id_7a35bd2c_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_trashentry core_trashentry_application_id_38c0c0a7_fk_core_application_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_trashentry
    ADD CONSTRAINT core_trashentry_application_id_38c0c0a7_fk_core_application_id FOREIGN KEY (application_id) REFERENCES public.core_application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_trashentry core_trashentry_trash_item_owner_id_8ebc2521_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_trashentry
    ADD CONSTRAINT core_trashentry_trash_item_owner_id_8ebc2521_fk_auth_user_id FOREIGN KEY (trash_item_owner_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_trashentry core_trashentry_user_who_trashed_id_9c115f8e_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_trashentry
    ADD CONSTRAINT core_trashentry_user_who_trashed_id_9c115f8e_fk_auth_user_id FOREIGN KEY (user_who_trashed_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_trashentry core_trashentry_workspace_id_4c567279_fk_core_workspace_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_trashentry
    ADD CONSTRAINT core_trashentry_workspace_id_4c567279_fk_core_workspace_id FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_twofactorauthprovidermodel core_twofactorauthpr_content_type_id_539a71bc_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_twofactorauthprovidermodel
    ADD CONSTRAINT core_twofactorauthpr_content_type_id_539a71bc_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_twofactorauthprovidermodel core_twofactorauthpr_user_id_b4d81adc_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_twofactorauthprovidermodel
    ADD CONSTRAINT core_twofactorauthpr_user_id_b4d81adc_fk_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_twofactorauthrecoverycode core_twofactorauthrecoverycode_user_id_9e3d96af_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_twofactorauthrecoverycode
    ADD CONSTRAINT core_twofactorauthrecoverycode_user_id_9e3d96af_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_userfile core_userfile_uploaded_by_id_9eaef00e_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_userfile
    ADD CONSTRAINT core_userfile_uploaded_by_id_9eaef00e_fk_auth_user_id FOREIGN KEY (uploaded_by_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_userlogentry core_userlogentry_actor_id_fb0b2f94_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_userlogentry
    ADD CONSTRAINT core_userlogentry_actor_id_fb0b2f94_fk_auth_user_id FOREIGN KEY (actor_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_userprofile core_userprofile_user_id_5141ad90_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_userprofile
    ADD CONSTRAINT core_userprofile_user_id_5141ad90_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_usersource core_usersource_application_id_36893a8a_fk_core_application_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_usersource
    ADD CONSTRAINT core_usersource_application_id_36893a8a_fk_core_application_id FOREIGN KEY (application_id) REFERENCES public.core_application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_usersource core_usersource_content_type_id_c1933b84_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_usersource
    ADD CONSTRAINT core_usersource_content_type_id_c1933b84_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_usersource core_usersource_integration_id_90c21eaa_fk_core_integration_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_usersource
    ADD CONSTRAINT core_usersource_integration_id_90c21eaa_fk_core_integration_id FOREIGN KEY (integration_id) REFERENCES public.core_integration(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_workspaceinvitation core_workspaceinvita_workspace_id_07099f26_fk_core_work; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workspaceinvitation
    ADD CONSTRAINT core_workspaceinvita_workspace_id_07099f26_fk_core_work FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: core_workspaceuser core_workspaceuser_workspace_id_c495e953_fk_core_workspace_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workspaceuser
    ADD CONSTRAINT core_workspaceuser_workspace_id_c495e953_fk_core_workspace_id FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dashboard_dashboard dashboard_dashboard_application_ptr_id_d1e3a295_fk_core_appl; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_dashboard
    ADD CONSTRAINT dashboard_dashboard_application_ptr_id_d1e3a295_fk_core_appl FOREIGN KEY (application_ptr_id) REFERENCES public.core_application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dashboard_dashboarddatasource dashboard_dashboardd_dashboard_id_7097f356_fk_dashboard; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_dashboarddatasource
    ADD CONSTRAINT dashboard_dashboardd_dashboard_id_7097f356_fk_dashboard FOREIGN KEY (dashboard_id) REFERENCES public.dashboard_dashboard(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dashboard_dashboarddatasource dashboard_dashboardd_service_id_13230fe5_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_dashboarddatasource
    ADD CONSTRAINT dashboard_dashboardd_service_id_13230fe5_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dashboard_summarywidget dashboard_summarywid_data_source_id_918e7169_fk_dashboard; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_summarywidget
    ADD CONSTRAINT dashboard_summarywid_data_source_id_918e7169_fk_dashboard FOREIGN KEY (data_source_id) REFERENCES public.dashboard_dashboarddatasource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dashboard_summarywidget dashboard_summarywid_widget_ptr_id_84e2d7a6_fk_dashboard; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_summarywidget
    ADD CONSTRAINT dashboard_summarywid_widget_ptr_id_84e2d7a6_fk_dashboard FOREIGN KEY (widget_ptr_id) REFERENCES public.dashboard_widget(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dashboard_widget dashboard_widget_content_type_id_c2b8e107_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_widget
    ADD CONSTRAINT dashboard_widget_content_type_id_c2b8e107_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dashboard_widget dashboard_widget_dashboard_id_d8c3f7af_fk_dashboard; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_widget
    ADD CONSTRAINT dashboard_widget_dashboard_id_d8c3f7af_fk_dashboard FOREIGN KEY (dashboard_id) REFERENCES public.dashboard_dashboard(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_airtableimportjob database_airtableimp_database_id_cc693ce8_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_airtableimportjob
    ADD CONSTRAINT database_airtableimp_database_id_cc693ce8_fk_database_ FOREIGN KEY (database_id) REFERENCES public.database_database(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_airtableimportjob database_airtableimp_workspace_id_f88f2137_fk_core_work; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_airtableimportjob
    ADD CONSTRAINT database_airtableimp_workspace_id_f88f2137_fk_core_work FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_airtableimportjob database_airtableimportjob_job_ptr_id_2509cd41_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_airtableimportjob
    ADD CONSTRAINT database_airtableimportjob_job_ptr_id_2509cd41_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_autonumberfield database_autonumberf_field_ptr_id_434750da_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_autonumberfield
    ADD CONSTRAINT database_autonumberf_field_ptr_id_434750da_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_booleanfield database_booleanfiel_field_ptr_id_de2eba2a_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_booleanfield
    ADD CONSTRAINT database_booleanfiel_field_ptr_id_de2eba2a_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_calendarviewfieldoptions database_calendarvie_calendar_view_id_d6160dbb_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_calendarviewfieldoptions
    ADD CONSTRAINT database_calendarvie_calendar_view_id_d6160dbb_fk_database_ FOREIGN KEY (calendar_view_id) REFERENCES public.database_calendarview(view_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_calendarview database_calendarvie_date_field_id_f7baa49c_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_calendarview
    ADD CONSTRAINT database_calendarvie_date_field_id_f7baa49c_fk_database_ FOREIGN KEY (date_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_calendarviewfieldoptions database_calendarvie_field_id_b4091352_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_calendarviewfieldoptions
    ADD CONSTRAINT database_calendarvie_field_id_b4091352_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_calendarview database_calendarview_view_ptr_id_88a23faf_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_calendarview
    ADD CONSTRAINT database_calendarview_view_ptr_id_88a23faf_fk_database_view_id FOREIGN KEY (view_ptr_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_countfield database_countfield_formulafield_ptr_id_138e0ad0_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_countfield
    ADD CONSTRAINT database_countfield_formulafield_ptr_id_138e0ad0_fk_database_ FOREIGN KEY (formulafield_ptr_id) REFERENCES public.database_formulafield(field_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_countfield database_countfield_through_field_id_47754f72_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_countfield
    ADD CONSTRAINT database_countfield_through_field_id_47754f72_fk_database_ FOREIGN KEY (through_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_createdbyfield database_createdbyfi_field_ptr_id_783389d8_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_createdbyfield
    ADD CONSTRAINT database_createdbyfi_field_ptr_id_783389d8_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_createdonfield database_createdonfi_field_ptr_id_88753d5b_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_createdonfield
    ADD CONSTRAINT database_createdonfi_field_ptr_id_88753d5b_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_database database_database_application_ptr_id_8cf9bdfe_fk_core_appl; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_database
    ADD CONSTRAINT database_database_application_ptr_id_8cf9bdfe_fk_core_appl FOREIGN KEY (application_ptr_id) REFERENCES public.core_application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_datasync database_datasync_content_type_id_518adc1d_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_datasync
    ADD CONSTRAINT database_datasync_content_type_id_518adc1d_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_datasync database_datasync_table_id_82d0ea5c_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_datasync
    ADD CONSTRAINT database_datasync_table_id_82d0ea5c_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_datasyncsyncedproperty database_datasyncsyn_data_sync_id_c9237ce1_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_datasyncsyncedproperty
    ADD CONSTRAINT database_datasyncsyn_data_sync_id_c9237ce1_fk_database_ FOREIGN KEY (data_sync_id) REFERENCES public.database_datasync(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_datasyncsyncedproperty database_datasyncsyn_field_id_4205e92c_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_datasyncsyncedproperty
    ADD CONSTRAINT database_datasyncsyn_field_id_4205e92c_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_datefield database_datefield_field_ptr_id_64c144c7_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_datefield
    ADD CONSTRAINT database_datefield_field_ptr_id_64c144c7_fk_database_field_id FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_duplicatefieldjob database_duplicatefi_duplicated_field_id_aa1284bd_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_duplicatefieldjob
    ADD CONSTRAINT database_duplicatefi_duplicated_field_id_aa1284bd_fk_database_ FOREIGN KEY (duplicated_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_duplicatefieldjob database_duplicatefi_original_field_id_a8d6be5d_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_duplicatefieldjob
    ADD CONSTRAINT database_duplicatefi_original_field_id_a8d6be5d_fk_database_ FOREIGN KEY (original_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_duplicatefieldjob database_duplicatefieldjob_job_ptr_id_9d23ea7e_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_duplicatefieldjob
    ADD CONSTRAINT database_duplicatefieldjob_job_ptr_id_9d23ea7e_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_duplicatetablejob database_duplicateta_duplicated_table_id_c05d1fd3_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_duplicatetablejob
    ADD CONSTRAINT database_duplicateta_duplicated_table_id_c05d1fd3_fk_database_ FOREIGN KEY (duplicated_table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_duplicatetablejob database_duplicateta_original_table_id_d3c02305_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_duplicatetablejob
    ADD CONSTRAINT database_duplicateta_original_table_id_d3c02305_fk_database_ FOREIGN KEY (original_table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_duplicatetablejob database_duplicatetablejob_job_ptr_id_4181e49c_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_duplicatetablejob
    ADD CONSTRAINT database_duplicatetablejob_job_ptr_id_4181e49c_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_durationfield database_durationfie_field_ptr_id_4a4c6fc8_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_durationfield
    ADD CONSTRAINT database_durationfie_field_ptr_id_4a4c6fc8_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_emailfield database_emailfield_field_ptr_id_55c4454d_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_emailfield
    ADD CONSTRAINT database_emailfield_field_ptr_id_55c4454d_fk_database_field_id FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_exportjob database_exportjob_table_id_9120c18e_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_exportjob
    ADD CONSTRAINT database_exportjob_table_id_9120c18e_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_exportjob database_exportjob_user_id_f9802097_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_exportjob
    ADD CONSTRAINT database_exportjob_user_id_f9802097_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_exportjob database_exportjob_view_id_a1d8052f_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_exportjob
    ADD CONSTRAINT database_exportjob_view_id_a1d8052f_fk_database_view_id FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_field database_field_content_type_id_3e7c32c9_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_field
    ADD CONSTRAINT database_field_content_type_id_3e7c32c9_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_field database_field_table_id_10109215_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_field
    ADD CONSTRAINT database_field_table_id_10109215_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_fieldconstraint database_fieldconstraint_field_id_ab382ba7_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fieldconstraint
    ADD CONSTRAINT database_fieldconstraint_field_id_ab382ba7_fk_database_field_id FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_fielddependency database_fielddepend_dependant_id_ca4b13bd_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fielddependency
    ADD CONSTRAINT database_fielddepend_dependant_id_ca4b13bd_fk_database_ FOREIGN KEY (dependant_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_fielddependency database_fielddepend_dependency_id_3dd1c05d_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fielddependency
    ADD CONSTRAINT database_fielddepend_dependency_id_3dd1c05d_fk_database_ FOREIGN KEY (dependency_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_fielddependency database_fielddepend_via_id_3ab567a8_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fielddependency
    ADD CONSTRAINT database_fielddepend_via_id_3ab567a8_fk_database_ FOREIGN KEY (via_id) REFERENCES public.database_linkrowfield(field_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_fieldrule database_fieldrule_content_type_id_8783421e_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fieldrule
    ADD CONSTRAINT database_fieldrule_content_type_id_8783421e_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_fieldrule database_fieldrule_table_id_b6fb8fb1_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fieldrule
    ADD CONSTRAINT database_fieldrule_table_id_b6fb8fb1_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_filefield database_filefield_field_ptr_id_ddd6cc93_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_filefield
    ADD CONSTRAINT database_filefield_field_ptr_id_ddd6cc93_fk_database_field_id FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_fileimportjob database_fileimportj_database_id_0566cd2d_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fileimportjob
    ADD CONSTRAINT database_fileimportj_database_id_0566cd2d_fk_database_ FOREIGN KEY (database_id) REFERENCES public.database_database(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_fileimportjob database_fileimportjob_job_ptr_id_679d11a7_fk_core_job_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fileimportjob
    ADD CONSTRAINT database_fileimportjob_job_ptr_id_679d11a7_fk_core_job_id FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_fileimportjob database_fileimportjob_table_id_7f90d810_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_fileimportjob
    ADD CONSTRAINT database_fileimportjob_table_id_7f90d810_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formulafield database_formulafiel_field_ptr_id_07f84168_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formulafield
    ADD CONSTRAINT database_formulafiel_field_ptr_id_07f84168_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formview database_formview_cover_image_id_19e4ffdc_fk_core_userfile_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formview
    ADD CONSTRAINT database_formview_cover_image_id_19e4ffdc_fk_core_userfile_id FOREIGN KEY (cover_image_id) REFERENCES public.core_userfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formview database_formview_logo_image_id_efa8caf1_fk_core_userfile_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formview
    ADD CONSTRAINT database_formview_logo_image_id_efa8caf1_fk_core_userfile_id FOREIGN KEY (logo_image_id) REFERENCES public.core_userfile(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formview_users_to_notify_on_submit database_formview_us_formview_id_0228f44e_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formview_users_to_notify_on_submit
    ADD CONSTRAINT database_formview_us_formview_id_0228f44e_fk_database_ FOREIGN KEY (formview_id) REFERENCES public.database_formview(view_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formview_users_to_notify_on_submit database_formview_us_user_id_a0179cf0_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formview_users_to_notify_on_submit
    ADD CONSTRAINT database_formview_us_user_id_a0179cf0_fk_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formview database_formview_view_ptr_id_49418f29_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formview
    ADD CONSTRAINT database_formview_view_ptr_id_49418f29_fk_database_view_id FOREIGN KEY (view_ptr_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formvieweditrowfield database_formviewedi_field_ptr_id_0e497c6f_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formvieweditrowfield
    ADD CONSTRAINT database_formviewedi_field_ptr_id_0e497c6f_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formvieweditrowfield database_formviewedi_form_view_id_8ac4e7d8_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formvieweditrowfield
    ADD CONSTRAINT database_formviewedi_form_view_id_8ac4e7d8_fk_database_ FOREIGN KEY (form_view_id) REFERENCES public.database_formview(view_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formviewfieldoptionscondition database_formviewfie_field_id_2cdb1588_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptionscondition
    ADD CONSTRAINT database_formviewfie_field_id_2cdb1588_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formviewfieldoptions database_formviewfie_field_id_37f2f750_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptions
    ADD CONSTRAINT database_formviewfie_field_id_37f2f750_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formviewfieldoptionsconditiongroup database_formviewfie_field_option_id_a9ffa2b5_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptionsconditiongroup
    ADD CONSTRAINT database_formviewfie_field_option_id_a9ffa2b5_fk_database_ FOREIGN KEY (field_option_id) REFERENCES public.database_formviewfieldoptions(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formviewfieldoptionscondition database_formviewfie_field_option_id_b48a9e1f_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptionscondition
    ADD CONSTRAINT database_formviewfie_field_option_id_b48a9e1f_fk_database_ FOREIGN KEY (field_option_id) REFERENCES public.database_formviewfieldoptions(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formviewfieldoptionsallowedselectoptions database_formviewfie_form_view_field_opti_e7eebddb_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptionsallowedselectoptions
    ADD CONSTRAINT database_formviewfie_form_view_field_opti_e7eebddb_fk_database_ FOREIGN KEY (form_view_field_options_id) REFERENCES public.database_formviewfieldoptions(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formviewfieldoptions database_formviewfie_form_view_id_374bdec5_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptions
    ADD CONSTRAINT database_formviewfie_form_view_id_374bdec5_fk_database_ FOREIGN KEY (form_view_id) REFERENCES public.database_formview(view_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formviewfieldoptionscondition database_formviewfie_group_id_ff7307cf_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptionscondition
    ADD CONSTRAINT database_formviewfie_group_id_ff7307cf_fk_database_ FOREIGN KEY (group_id) REFERENCES public.database_formviewfieldoptionsconditiongroup(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formviewfieldoptionsconditiongroup database_formviewfie_parent_group_id_4f199881_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptionsconditiongroup
    ADD CONSTRAINT database_formviewfie_parent_group_id_4f199881_fk_database_ FOREIGN KEY (parent_group_id) REFERENCES public.database_formviewfieldoptionsconditiongroup(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_formviewfieldoptionsallowedselectoptions database_formviewfie_select_option_id_9bd1c913_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_formviewfieldoptionsallowedselectoptions
    ADD CONSTRAINT database_formviewfie_select_option_id_9bd1c913_fk_database_ FOREIGN KEY (select_option_id) REFERENCES public.database_selectoption(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_galleryview database_galleryview_card_cover_image_fie_61ed6620_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_galleryview
    ADD CONSTRAINT database_galleryview_card_cover_image_fie_61ed6620_fk_database_ FOREIGN KEY (card_cover_image_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_galleryviewfieldoptions database_galleryview_field_id_541e78db_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_galleryviewfieldoptions
    ADD CONSTRAINT database_galleryview_field_id_541e78db_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_galleryviewfieldoptions database_galleryview_gallery_view_id_622189d6_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_galleryviewfieldoptions
    ADD CONSTRAINT database_galleryview_gallery_view_id_622189d6_fk_database_ FOREIGN KEY (gallery_view_id) REFERENCES public.database_galleryview(view_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_galleryview database_galleryview_view_ptr_id_ef4c6c9f_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_galleryview
    ADD CONSTRAINT database_galleryview_view_ptr_id_ef4c6c9f_fk_database_view_id FOREIGN KEY (view_ptr_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_gridview database_gridview_view_ptr_id_58e55889_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_gridview
    ADD CONSTRAINT database_gridview_view_ptr_id_58e55889_fk_database_view_id FOREIGN KEY (view_ptr_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_gridviewfieldoptions database_gridviewfie_field_id_5808d604_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_gridviewfieldoptions
    ADD CONSTRAINT database_gridviewfie_field_id_5808d604_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_gridviewfieldoptions database_gridviewfie_grid_view_id_b537505b_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_gridviewfieldoptions
    ADD CONSTRAINT database_gridviewfie_grid_view_id_b537505b_fk_database_ FOREIGN KEY (grid_view_id) REFERENCES public.database_gridview(view_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_icalcalendardatasync database_icalcalenda_datasync_ptr_id_6144594b_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_icalcalendardatasync
    ADD CONSTRAINT database_icalcalenda_datasync_ptr_id_6144594b_fk_database_ FOREIGN KEY (datasync_ptr_id) REFERENCES public.database_datasync(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_kanbanview database_kanbanview_card_cover_image_fie_5bd91f16_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_kanbanview
    ADD CONSTRAINT database_kanbanview_card_cover_image_fie_5bd91f16_fk_database_ FOREIGN KEY (card_cover_image_field_id) REFERENCES public.database_filefield(field_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_kanbanview database_kanbanview_single_select_field__b06a8b52_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_kanbanview
    ADD CONSTRAINT database_kanbanview_single_select_field__b06a8b52_fk_database_ FOREIGN KEY (single_select_field_id) REFERENCES public.database_singleselectfield(field_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_kanbanview database_kanbanview_view_ptr_id_87acf8af_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_kanbanview
    ADD CONSTRAINT database_kanbanview_view_ptr_id_87acf8af_fk_database_view_id FOREIGN KEY (view_ptr_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_kanbanviewfieldoptions database_kanbanviewf_field_id_257bb004_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_kanbanviewfieldoptions
    ADD CONSTRAINT database_kanbanviewf_field_id_257bb004_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_kanbanviewfieldoptions database_kanbanviewf_kanban_view_id_d7b70bb3_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_kanbanviewfieldoptions
    ADD CONSTRAINT database_kanbanviewf_kanban_view_id_d7b70bb3_fk_database_ FOREIGN KEY (kanban_view_id) REFERENCES public.database_kanbanview(view_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_lastmodifiedfield database_lastmodifie_field_ptr_id_438b8151_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_lastmodifiedfield
    ADD CONSTRAINT database_lastmodifie_field_ptr_id_438b8151_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_lastmodifiedbyfield database_lastmodifie_field_ptr_id_96003c3f_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_lastmodifiedbyfield
    ADD CONSTRAINT database_lastmodifie_field_ptr_id_96003c3f_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_linkrowfield database_linkrowfiel_field_ptr_id_3019febf_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_linkrowfield
    ADD CONSTRAINT database_linkrowfiel_field_ptr_id_3019febf_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_linkrowfield database_linkrowfiel_link_row_limit_selec_54c4559f_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_linkrowfield
    ADD CONSTRAINT database_linkrowfiel_link_row_limit_selec_54c4559f_fk_database_ FOREIGN KEY (link_row_limit_selection_view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_linkrowfield database_linkrowfiel_link_row_related_fie_0d56e726_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_linkrowfield
    ADD CONSTRAINT database_linkrowfiel_link_row_related_fie_0d56e726_fk_database_ FOREIGN KEY (link_row_related_field_id) REFERENCES public.database_linkrowfield(field_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_linkrowfield database_linkrowfiel_link_row_table_id_84dbb70f_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_linkrowfield
    ADD CONSTRAINT database_linkrowfiel_link_row_table_id_84dbb70f_fk_database_ FOREIGN KEY (link_row_table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_longtextfield database_longtextfie_field_ptr_id_82e0be13_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_longtextfield
    ADD CONSTRAINT database_longtextfie_field_ptr_id_82e0be13_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_lookupfield database_lookupfield_formulafield_ptr_id_674e1aa4_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_lookupfield
    ADD CONSTRAINT database_lookupfield_formulafield_ptr_id_674e1aa4_fk_database_ FOREIGN KEY (formulafield_ptr_id) REFERENCES public.database_formulafield(field_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_lookupfield database_lookupfield_target_field_id_7c9df7fa_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_lookupfield
    ADD CONSTRAINT database_lookupfield_target_field_id_7c9df7fa_fk_database_ FOREIGN KEY (target_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_lookupfield database_lookupfield_through_field_id_377bb9ac_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_lookupfield
    ADD CONSTRAINT database_lookupfield_through_field_id_377bb9ac_fk_database_ FOREIGN KEY (through_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_multiplecollaboratorsfield database_multiplecol_field_ptr_id_c7baf5a1_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_multiplecollaboratorsfield
    ADD CONSTRAINT database_multiplecol_field_ptr_id_c7baf5a1_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_multipleselectfield database_multiplesel_field_ptr_id_b6468f75_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_multipleselectfield
    ADD CONSTRAINT database_multiplesel_field_ptr_id_b6468f75_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_numberfield database_numberfield_field_ptr_id_0b2712cf_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_numberfield
    ADD CONSTRAINT database_numberfield_field_ptr_id_0b2712cf_fk_database_field_id FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_passwordfield database_passwordfie_field_ptr_id_8fcf9899_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_passwordfield
    ADD CONSTRAINT database_passwordfie_field_ptr_id_8fcf9899_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_pendingsearchvalueupdate database_pendingsear_table_id_813adfd1_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_pendingsearchvalueupdate
    ADD CONSTRAINT database_pendingsear_table_id_813adfd1_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_phonenumberfield database_phonenumber_field_ptr_id_44d9cc53_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_phonenumberfield
    ADD CONSTRAINT database_phonenumber_field_ptr_id_44d9cc53_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_postgresqldatasync database_postgresqld_datasync_ptr_id_fcbf48bd_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_postgresqldatasync
    ADD CONSTRAINT database_postgresqld_datasync_ptr_id_fcbf48bd_fk_database_ FOREIGN KEY (datasync_ptr_id) REFERENCES public.database_datasync(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_ratingfield database_ratingfield_field_ptr_id_20c779f9_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_ratingfield
    ADD CONSTRAINT database_ratingfield_field_ptr_id_20c779f9_fk_database_field_id FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_richtextfieldmention database_richtextfie_field_id_eac6a7be_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_richtextfieldmention
    ADD CONSTRAINT database_richtextfie_field_id_eac6a7be_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_richtextfieldmention database_richtextfie_table_id_08b90768_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_richtextfieldmention
    ADD CONSTRAINT database_richtextfie_table_id_08b90768_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_richtextfieldmention database_richtextfieldmention_user_id_ee90bcaa_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_richtextfieldmention
    ADD CONSTRAINT database_richtextfieldmention_user_id_ee90bcaa_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_rollupfield database_rollupfield_formulafield_ptr_id_6717ae39_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rollupfield
    ADD CONSTRAINT database_rollupfield_formulafield_ptr_id_6717ae39_fk_database_ FOREIGN KEY (formulafield_ptr_id) REFERENCES public.database_formulafield(field_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_rollupfield database_rollupfield_target_field_id_e514ae8b_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rollupfield
    ADD CONSTRAINT database_rollupfield_target_field_id_e514ae8b_fk_database_ FOREIGN KEY (target_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_rollupfield database_rollupfield_through_field_id_a35fa95f_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rollupfield
    ADD CONSTRAINT database_rollupfield_through_field_id_a35fa95f_fk_database_ FOREIGN KEY (through_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_rowcomment_mentions database_rowcomment__rowcomment_id_dc56cf9b_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rowcomment_mentions
    ADD CONSTRAINT database_rowcomment__rowcomment_id_dc56cf9b_fk_database_ FOREIGN KEY (rowcomment_id) REFERENCES public.database_rowcomment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_rowcomment_mentions database_rowcomment_mentions_user_id_49a137b9_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rowcomment_mentions
    ADD CONSTRAINT database_rowcomment_mentions_user_id_49a137b9_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_rowcomment database_rowcomment_table_id_5878d1c7_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rowcomment
    ADD CONSTRAINT database_rowcomment_table_id_5878d1c7_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_rowcomment database_rowcomment_user_id_d0408bb6_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rowcomment
    ADD CONSTRAINT database_rowcomment_user_id_d0408bb6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_rowhistory database_rowhistory_table_id_8e564277_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_rowhistory
    ADD CONSTRAINT database_rowhistory_table_id_8e564277_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_selectoption database_selectoption_field_id_308591f6_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_selectoption
    ADD CONSTRAINT database_selectoption_field_id_308591f6_fk_database_field_id FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_singleselectfield database_singleselec_field_ptr_id_56c0f702_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_singleselectfield
    ADD CONSTRAINT database_singleselec_field_ptr_id_56c0f702_fk_database_ FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_syncdatasynctablejob database_syncdatasyn_data_sync_id_07969c0e_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_syncdatasynctablejob
    ADD CONSTRAINT database_syncdatasyn_data_sync_id_07969c0e_fk_database_ FOREIGN KEY (data_sync_id) REFERENCES public.database_datasync(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_syncdatasynctablejob database_syncdatasyn_job_ptr_id_48e9a195_fk_core_job_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_syncdatasynctablejob
    ADD CONSTRAINT database_syncdatasyn_job_ptr_id_48e9a195_fk_core_job_ FOREIGN KEY (job_ptr_id) REFERENCES public.core_job(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_table database_table_database_id_94b826f0_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_table
    ADD CONSTRAINT database_table_database_id_94b826f0_fk_database_ FOREIGN KEY (database_id) REFERENCES public.database_database(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tableusage database_tableusage_table_id_3db6891e_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tableusage
    ADD CONSTRAINT database_tableusage_table_id_3db6891e_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tableusageupdate database_tableusageu_table_id_6a388b33_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tableusageupdate
    ADD CONSTRAINT database_tableusageu_table_id_6a388b33_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tablewebhookevent_fields database_tablewebhoo_field_id_49fa85df_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookevent_fields
    ADD CONSTRAINT database_tablewebhoo_field_id_49fa85df_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tablewebhookevent_fields database_tablewebhoo_tablewebhookevent_id_0e4ceb82_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookevent_fields
    ADD CONSTRAINT database_tablewebhoo_tablewebhookevent_id_0e4ceb82_fk_database_ FOREIGN KEY (tablewebhookevent_id) REFERENCES public.database_tablewebhookevent(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tablewebhookevent_views database_tablewebhoo_tablewebhookevent_id_39df6a86_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookevent_views
    ADD CONSTRAINT database_tablewebhoo_tablewebhookevent_id_39df6a86_fk_database_ FOREIGN KEY (tablewebhookevent_id) REFERENCES public.database_tablewebhookevent(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tablewebhookevent_views database_tablewebhoo_view_id_cb0adf58_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookevent_views
    ADD CONSTRAINT database_tablewebhoo_view_id_cb0adf58_fk_database_ FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tablewebhookcall database_tablewebhoo_webhook_id_333e8ad1_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookcall
    ADD CONSTRAINT database_tablewebhoo_webhook_id_333e8ad1_fk_database_ FOREIGN KEY (webhook_id) REFERENCES public.database_tablewebhook(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tablewebhookevent database_tablewebhoo_webhook_id_8fca798d_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookevent
    ADD CONSTRAINT database_tablewebhoo_webhook_id_8fca798d_fk_database_ FOREIGN KEY (webhook_id) REFERENCES public.database_tablewebhook(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tablewebhookheader database_tablewebhoo_webhook_id_a879ecb4_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhookheader
    ADD CONSTRAINT database_tablewebhoo_webhook_id_a879ecb4_fk_database_ FOREIGN KEY (webhook_id) REFERENCES public.database_tablewebhook(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tablewebhook database_tablewebhook_table_id_bded0cad_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tablewebhook
    ADD CONSTRAINT database_tablewebhook_table_id_bded0cad_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_textfield database_textfield_field_ptr_id_f87f8cd8_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_textfield
    ADD CONSTRAINT database_textfield_field_ptr_id_f87f8cd8_fk_database_field_id FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_timelineview database_timelinevie_end_date_field_id_99df68f6_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_timelineview
    ADD CONSTRAINT database_timelinevie_end_date_field_id_99df68f6_fk_database_ FOREIGN KEY (end_date_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_timelineviewfieldoptions database_timelinevie_field_id_be312ccc_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_timelineviewfieldoptions
    ADD CONSTRAINT database_timelinevie_field_id_be312ccc_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_timelineview database_timelinevie_start_date_field_id_da708390_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_timelineview
    ADD CONSTRAINT database_timelinevie_start_date_field_id_da708390_fk_database_ FOREIGN KEY (start_date_field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_timelineviewfieldoptions database_timelinevie_timeline_view_id_4840a23c_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_timelineviewfieldoptions
    ADD CONSTRAINT database_timelinevie_timeline_view_id_4840a23c_fk_database_ FOREIGN KEY (timeline_view_id) REFERENCES public.database_timelineview(view_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_timelineview database_timelineview_view_ptr_id_d7ee5635_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_timelineview
    ADD CONSTRAINT database_timelineview_view_ptr_id_d7ee5635_fk_database_view_id FOREIGN KEY (view_ptr_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_token database_token_user_id_09848757_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_token
    ADD CONSTRAINT database_token_user_id_09848757_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_token database_token_workspace_id_8319ebdf_fk_core_workspace_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_token
    ADD CONSTRAINT database_token_workspace_id_8319ebdf_fk_core_workspace_id FOREIGN KEY (workspace_id) REFERENCES public.core_workspace(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tokenpermission database_tokenpermis_database_id_fcb9f74f_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tokenpermission
    ADD CONSTRAINT database_tokenpermis_database_id_fcb9f74f_fk_database_ FOREIGN KEY (database_id) REFERENCES public.database_database(application_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tokenpermission database_tokenpermission_table_id_52facb2e_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tokenpermission
    ADD CONSTRAINT database_tokenpermission_table_id_52facb2e_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_tokenpermission database_tokenpermission_token_id_d06a00dc_fk_database_token_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_tokenpermission
    ADD CONSTRAINT database_tokenpermission_token_id_d06a00dc_fk_database_token_id FOREIGN KEY (token_id) REFERENCES public.database_token(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_trashedrows database_trashedrows_table_id_b0682470_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_trashedrows
    ADD CONSTRAINT database_trashedrows_table_id_b0682470_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_urlfield database_urlfield_field_ptr_id_39f2566a_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_urlfield
    ADD CONSTRAINT database_urlfield_field_ptr_id_39f2566a_fk_database_field_id FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_uuidfield database_uuidfield_field_ptr_id_f563bc47_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_uuidfield
    ADD CONSTRAINT database_uuidfield_field_ptr_id_f563bc47_fk_database_field_id FOREIGN KEY (field_ptr_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_view database_view_content_type_id_6bf2b2bf_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_view
    ADD CONSTRAINT database_view_content_type_id_6bf2b2bf_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_view database_view_created_by_id_b036ac75_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_view
    ADD CONSTRAINT database_view_created_by_id_b036ac75_fk_auth_user_id FOREIGN KEY (created_by_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_view database_view_table_id_aa8270d1_fk_database_table_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_view
    ADD CONSTRAINT database_view_table_id_aa8270d1_fk_database_table_id FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewdecoration database_viewdecoration_view_id_b60ac1b2_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewdecoration
    ADD CONSTRAINT database_viewdecoration_view_id_b60ac1b2_fk_database_view_id FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewdefaultvalue database_viewdefault_field_id_27a1812e_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewdefaultvalue
    ADD CONSTRAINT database_viewdefault_field_id_27a1812e_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewdefaultvalue database_viewdefaultvalue_view_id_a16c1406_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewdefaultvalue
    ADD CONSTRAINT database_viewdefaultvalue_view_id_a16c1406_fk_database_view_id FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewfilter database_viewfilter_field_id_5f1868dc_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewfilter
    ADD CONSTRAINT database_viewfilter_field_id_5f1868dc_fk_database_field_id FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewfilter database_viewfilter_group_id_d611d031_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewfilter
    ADD CONSTRAINT database_viewfilter_group_id_d611d031_fk_database_ FOREIGN KEY (group_id) REFERENCES public.database_viewfiltergroup(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewfilter database_viewfilter_view_id_4a62ccde_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewfilter
    ADD CONSTRAINT database_viewfilter_view_id_4a62ccde_fk_database_view_id FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewfiltergroup database_viewfilterg_parent_group_id_5a6d8b73_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewfiltergroup
    ADD CONSTRAINT database_viewfilterg_parent_group_id_5a6d8b73_fk_database_ FOREIGN KEY (parent_group_id) REFERENCES public.database_viewfiltergroup(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewfiltergroup database_viewfiltergroup_view_id_84806393_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewfiltergroup
    ADD CONSTRAINT database_viewfiltergroup_view_id_84806393_fk_database_view_id FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewgroupby database_viewgroupby_field_id_a79fc066_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewgroupby
    ADD CONSTRAINT database_viewgroupby_field_id_a79fc066_fk_database_field_id FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewgroupby database_viewgroupby_view_id_24658e5d_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewgroupby
    ADD CONSTRAINT database_viewgroupby_view_id_24658e5d_fk_database_view_id FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewrows database_viewrows_view_id_a02e206e_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewrows
    ADD CONSTRAINT database_viewrows_view_id_a02e206e_fk_database_view_id FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewsort database_viewsort_field_id_e51d1ca2_fk_database_field_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewsort
    ADD CONSTRAINT database_viewsort_field_id_e51d1ca2_fk_database_field_id FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewsort database_viewsort_view_id_2e9d197f_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewsort
    ADD CONSTRAINT database_viewsort_view_id_2e9d197f_fk_database_view_id FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewsubscription database_viewsubscri_subscriber_content_t_780900e9_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewsubscription
    ADD CONSTRAINT database_viewsubscri_subscriber_content_t_780900e9_fk_django_co FOREIGN KEY (subscriber_content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: database_viewsubscription database_viewsubscription_view_id_0ecdfe73_fk_database_view_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_viewsubscription
    ADD CONSTRAINT database_viewsubscription_view_id_0ecdfe73_fk_database_view_id FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_aiagentservice integrations_aiagent_service_ptr_id_bc411278_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_aiagentservice
    ADD CONSTRAINT integrations_aiagent_service_ptr_id_bc411278_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_aiintegration integrations_aiinteg_integration_ptr_id_84ce8fa6_fk_core_inte; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_aiintegration
    ADD CONSTRAINT integrations_aiinteg_integration_ptr_id_84ce8fa6_fk_core_inte FOREIGN KEY (integration_ptr_id) REFERENCES public.core_integration(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_corecsvfilereaderservice integrations_corecsv_service_ptr_id_71896d4f_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corecsvfilereaderservice
    ADD CONSTRAINT integrations_corecsv_service_ptr_id_71896d4f_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_corehttptriggerservice integrations_corehtt_service_ptr_id_2179e709_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corehttptriggerservice
    ADD CONSTRAINT integrations_corehtt_service_ptr_id_2179e709_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_corehttprequestservice integrations_corehtt_service_ptr_id_9fa64e38_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corehttprequestservice
    ADD CONSTRAINT integrations_corehtt_service_ptr_id_9fa64e38_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_coreiteratorservice integrations_coreite_service_ptr_id_8a3e3fff_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_coreiteratorservice
    ADD CONSTRAINT integrations_coreite_service_ptr_id_8a3e3fff_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_coremanualtriggerservice integrations_coreman_service_ptr_id_9e86c6c6_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_coremanualtriggerservice
    ADD CONSTRAINT integrations_coreman_service_ptr_id_9e86c6c6_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_coreperiodicservice integrations_coreper_service_ptr_id_2f5d947f_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_coreperiodicservice
    ADD CONSTRAINT integrations_coreper_service_ptr_id_2f5d947f_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_corerouterserviceedge integrations_corerou_service_id_84a34663_fk_integrati; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corerouterserviceedge
    ADD CONSTRAINT integrations_corerou_service_id_84a34663_fk_integrati FOREIGN KEY (service_id) REFERENCES public.integrations_corerouterservice(service_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_corerouterservice integrations_corerou_service_ptr_id_29a31aba_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corerouterservice
    ADD CONSTRAINT integrations_corerou_service_ptr_id_29a31aba_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_coresmtpemailservice integrations_coresmt_service_ptr_id_909ee89d_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_coresmtpemailservice
    ADD CONSTRAINT integrations_coresmt_service_ptr_id_909ee89d_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_corestartworkflowservice integrations_coresta_service_ptr_id_cf4d5a87_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corestartworkflowservice
    ADD CONSTRAINT integrations_coresta_service_ptr_id_cf4d5a87_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_corestartworkflowservice integrations_coresta_workflow_id_ce86e333_fk_automatio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_corestartworkflowservice
    ADD CONSTRAINT integrations_coresta_workflow_id_ce86e333_fk_automatio FOREIGN KEY (workflow_id) REFERENCES public.automation_automationworkflow(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_httpformdata integrations_httpfor_service_id_2c110352_fk_integrati; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_httpformdata
    ADD CONSTRAINT integrations_httpfor_service_id_2c110352_fk_integrati FOREIGN KEY (service_id) REFERENCES public.integrations_corehttprequestservice(service_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_httpheader integrations_httphea_service_id_ce8b90dc_fk_integrati; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_httpheader
    ADD CONSTRAINT integrations_httphea_service_id_ce8b90dc_fk_integrati FOREIGN KEY (service_id) REFERENCES public.integrations_corehttprequestservice(service_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_httpqueryparam integrations_httpque_service_id_da61613b_fk_integrati; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_httpqueryparam
    ADD CONSTRAINT integrations_httpque_service_id_da61613b_fk_integrati FOREIGN KEY (service_id) REFERENCES public.integrations_corehttprequestservice(service_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowintegration integrations_localba_authorized_user_id_8dd67891_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowintegration
    ADD CONSTRAINT integrations_localba_authorized_user_id_8dd67891_fk_auth_user FOREIGN KEY (authorized_user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowaggregaterows integrations_localba_field_id_16983939_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowaggregaterows
    ADD CONSTRAINT integrations_localba_field_id_16983939_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowtableservicefieldmapping integrations_localba_field_id_1f7d5505_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowtableservicefieldmapping
    ADD CONSTRAINT integrations_localba_field_id_1f7d5505_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowtableservicefilter integrations_localba_field_id_53e82940_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowtableservicefilter
    ADD CONSTRAINT integrations_localba_field_id_53e82940_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowfieldsupdated_fields integrations_localba_field_id_92ac24c6_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowfieldsupdated_fields
    ADD CONSTRAINT integrations_localba_field_id_92ac24c6_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowtableservicesort integrations_localba_field_id_f9dff360_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowtableservicesort
    ADD CONSTRAINT integrations_localba_field_id_f9dff360_fk_database_ FOREIGN KEY (field_id) REFERENCES public.database_field(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowintegration integrations_localba_integration_ptr_id_c4976106_fk_core_inte; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowintegration
    ADD CONSTRAINT integrations_localba_integration_ptr_id_c4976106_fk_core_inte FOREIGN KEY (integration_ptr_id) REFERENCES public.core_integration(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowfieldsupdated_fields integrations_localba_localbaserowfieldsup_d9f7bc69_fk_integrati; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowfieldsupdated_fields
    ADD CONSTRAINT integrations_localba_localbaserowfieldsup_d9f7bc69_fk_integrati FOREIGN KEY (localbaserowfieldsupdated_id) REFERENCES public.integrations_localbaserowfieldsupdated(service_ptr_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowtableservicefilter integrations_localba_service_id_51c2e8fa_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowtableservicefilter
    ADD CONSTRAINT integrations_localba_service_id_51c2e8fa_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowtableservicesort integrations_localba_service_id_d63d5b4c_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowtableservicesort
    ADD CONSTRAINT integrations_localba_service_id_d63d5b4c_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowtableservicefieldmapping integrations_localba_service_id_df624c41_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowtableservicefieldmapping
    ADD CONSTRAINT integrations_localba_service_id_df624c41_fk_core_serv FOREIGN KEY (service_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowaggregaterows integrations_localba_service_ptr_id_02612353_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowaggregaterows
    ADD CONSTRAINT integrations_localba_service_ptr_id_02612353_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowcreaterows integrations_localba_service_ptr_id_1e1e05f7_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowcreaterows
    ADD CONSTRAINT integrations_localba_service_ptr_id_1e1e05f7_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowdeleterow integrations_localba_service_ptr_id_237ff5d7_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowdeleterow
    ADD CONSTRAINT integrations_localba_service_ptr_id_237ff5d7_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowfieldsupdated integrations_localba_service_ptr_id_5e479d46_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowfieldsupdated
    ADD CONSTRAINT integrations_localba_service_ptr_id_5e479d46_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowrowsupdated integrations_localba_service_ptr_id_6ea21557_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowrowsupdated
    ADD CONSTRAINT integrations_localba_service_ptr_id_6ea21557_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowgetrow integrations_localba_service_ptr_id_7e459844_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowgetrow
    ADD CONSTRAINT integrations_localba_service_ptr_id_7e459844_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowupdaterows integrations_localba_service_ptr_id_942bbc76_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowupdaterows
    ADD CONSTRAINT integrations_localba_service_ptr_id_942bbc76_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowupsertrow integrations_localba_service_ptr_id_9fd69568_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowupsertrow
    ADD CONSTRAINT integrations_localba_service_ptr_id_9fd69568_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowrowsdeleted integrations_localba_service_ptr_id_d687e8cd_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowrowsdeleted
    ADD CONSTRAINT integrations_localba_service_ptr_id_d687e8cd_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowrowscreated integrations_localba_service_ptr_id_e634b48c_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowrowscreated
    ADD CONSTRAINT integrations_localba_service_ptr_id_e634b48c_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowlistrows integrations_localba_service_ptr_id_f2c14271_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowlistrows
    ADD CONSTRAINT integrations_localba_service_ptr_id_f2c14271_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowrowsupdated integrations_localba_table_id_02483e2b_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowrowsupdated
    ADD CONSTRAINT integrations_localba_table_id_02483e2b_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowcreaterows integrations_localba_table_id_1b0874e7_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowcreaterows
    ADD CONSTRAINT integrations_localba_table_id_1b0874e7_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowlistrows integrations_localba_table_id_21a3492c_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowlistrows
    ADD CONSTRAINT integrations_localba_table_id_21a3492c_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowaggregaterows integrations_localba_table_id_57c8661c_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowaggregaterows
    ADD CONSTRAINT integrations_localba_table_id_57c8661c_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowupdaterows integrations_localba_table_id_7350e0ec_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowupdaterows
    ADD CONSTRAINT integrations_localba_table_id_7350e0ec_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowrowsdeleted integrations_localba_table_id_91fd1fbc_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowrowsdeleted
    ADD CONSTRAINT integrations_localba_table_id_91fd1fbc_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowrowscreated integrations_localba_table_id_97301d6a_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowrowscreated
    ADD CONSTRAINT integrations_localba_table_id_97301d6a_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowdeleterow integrations_localba_table_id_a8d1e413_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowdeleterow
    ADD CONSTRAINT integrations_localba_table_id_a8d1e413_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowfieldsupdated integrations_localba_table_id_c2a807c4_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowfieldsupdated
    ADD CONSTRAINT integrations_localba_table_id_c2a807c4_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowupsertrow integrations_localba_table_id_c9f8d243_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowupsertrow
    ADD CONSTRAINT integrations_localba_table_id_c9f8d243_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowgetrow integrations_localba_table_id_f0a221b2_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowgetrow
    ADD CONSTRAINT integrations_localba_table_id_f0a221b2_fk_database_ FOREIGN KEY (table_id) REFERENCES public.database_table(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowlistrows integrations_localba_view_id_439c037e_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowlistrows
    ADD CONSTRAINT integrations_localba_view_id_439c037e_fk_database_ FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowaggregaterows integrations_localba_view_id_47ec4d91_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowaggregaterows
    ADD CONSTRAINT integrations_localba_view_id_47ec4d91_fk_database_ FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_localbaserowgetrow integrations_localba_view_id_bb09abe6_fk_database_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_localbaserowgetrow
    ADD CONSTRAINT integrations_localba_view_id_bb09abe6_fk_database_ FOREIGN KEY (view_id) REFERENCES public.database_view(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_slackbotintegration integrations_slackbo_integration_ptr_id_ee8f2cff_fk_core_inte; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_slackbotintegration
    ADD CONSTRAINT integrations_slackbo_integration_ptr_id_ee8f2cff_fk_core_inte FOREIGN KEY (integration_ptr_id) REFERENCES public.core_integration(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_slackwritemessageservice integrations_slackwr_service_ptr_id_da100ff4_fk_core_serv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_slackwritemessageservice
    ADD CONSTRAINT integrations_slackwr_service_ptr_id_da100ff4_fk_core_serv FOREIGN KEY (service_ptr_id) REFERENCES public.core_service(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: integrations_smtpintegration integrations_smtpint_integration_ptr_id_c04fda33_fk_core_inte; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations_smtpintegration
    ADD CONSTRAINT integrations_smtpint_integration_ptr_id_c04fda33_fk_core_inte FOREIGN KEY (integration_ptr_id) REFERENCES public.core_integration(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--


