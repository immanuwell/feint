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
-- Name: action_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.action_kind AS ENUM (
    'create',
    'update',
    'delete',
    'execute'
);


--
-- Name: asset_access_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.asset_access_type AS ENUM (
    'r',
    'w',
    'rw'
);


--
-- Name: asset_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.asset_kind AS ENUM (
    's3object',
    'resource',
    'variable',
    'ducklake',
    'datatable',
    'volume',
    'dbt'
);


--
-- Name: asset_usage_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.asset_usage_kind AS ENUM (
    'script',
    'flow',
    'job'
);


--
-- Name: authentication_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.authentication_method AS ENUM (
    'none',
    'windmill',
    'api_key',
    'basic_http',
    'custom_script',
    'signature'
);


--
-- Name: autoscaling_event_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.autoscaling_event_type AS ENUM (
    'full_scaleout',
    'scalein',
    'scaleout'
);


--
-- Name: aws_auth_resource_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.aws_auth_resource_type AS ENUM (
    'oidc',
    'credentials'
);


--
-- Name: azure_trigger_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.azure_trigger_mode AS ENUM (
    'basic_push',
    'namespace_push',
    'namespace_pull'
);


--
-- Name: delivery_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.delivery_mode AS ENUM (
    'push',
    'pull'
);


--
-- Name: dispatch_outcome; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.dispatch_outcome AS ENUM (
    'dispatched',
    'join_pending',
    'skipped'
);


--
-- Name: draft_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.draft_kind AS ENUM (
    'script',
    'flow',
    'app',
    'raw_app',
    'resource',
    'variable',
    'trigger_schedule',
    'trigger_webhook',
    'trigger_default_email',
    'trigger_email',
    'trigger_http',
    'trigger_websocket',
    'trigger_postgres',
    'trigger_kafka',
    'trigger_nats',
    'trigger_mqtt',
    'trigger_sqs',
    'trigger_gcp',
    'trigger_azure',
    'trigger_poll',
    'trigger_cli',
    'trigger_nextcloud',
    'trigger_google',
    'trigger_github',
    'data_pipeline',
    'trigger_amqp'
);


--
-- Name: favorite_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.favorite_kind AS ENUM (
    'app',
    'script',
    'flow',
    'raw_app',
    'asset'
);


--
-- Name: gcp_subscription_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.gcp_subscription_mode AS ENUM (
    'create_update',
    'existing'
);


--
-- Name: http_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.http_method AS ENUM (
    'get',
    'post',
    'put',
    'delete',
    'patch'
);


--
-- Name: importer_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.importer_kind AS ENUM (
    'script',
    'flow',
    'app'
);


--
-- Name: job_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.job_kind AS ENUM (
    'script',
    'preview',
    'flow',
    'dependencies',
    'flowpreview',
    'script_hub',
    'identity',
    'flowdependencies',
    'http',
    'graphql',
    'postgresql',
    'noop',
    'appdependencies',
    'deploymentcallback',
    'singlestepflow',
    'flowscript',
    'flownode',
    'appscript',
    'aiagent',
    'unassigned_script',
    'unassigned_flow',
    'unassigned_singlestepflow'
);


--
-- Name: job_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.job_status AS ENUM (
    'success',
    'failure',
    'canceled',
    'skipped'
);


--
-- Name: job_trigger_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.job_trigger_kind AS ENUM (
    'webhook',
    'http',
    'websocket',
    'kafka',
    'email',
    'nats',
    'schedule',
    'app',
    'ui',
    'postgres',
    'sqs',
    'gcp',
    'mqtt',
    'nextcloud',
    'google',
    'ci_test',
    'github',
    'azure',
    'asset',
    'freshness',
    'amqp'
);


--
-- Name: log_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.log_mode AS ENUM (
    'standalone',
    'server',
    'worker',
    'agent',
    'indexer',
    'mcp'
);


--
-- Name: login_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.login_type AS ENUM (
    'password',
    'github'
);


--
-- Name: materialization_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.materialization_status AS ENUM (
    'running',
    'materialized',
    'failed'
);


--
-- Name: message_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.message_type AS ENUM (
    'user',
    'assistant',
    'tool'
);


--
-- Name: metric_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.metric_kind AS ENUM (
    'scalar_int',
    'scalar_float',
    'timeseries_int',
    'timeseries_float'
);


--
-- Name: mqtt_client_version; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.mqtt_client_version AS ENUM (
    'v3',
    'v5'
);


--
-- Name: native_trigger_service; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.native_trigger_service AS ENUM (
    'nextcloud',
    'google',
    'github'
);


--
-- Name: request_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_type AS ENUM (
    'sync',
    'async',
    'sync_sse'
);


--
-- Name: runnable_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.runnable_type AS ENUM (
    'ScriptHash',
    'ScriptPath',
    'FlowPath'
);


--
-- Name: script_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.script_kind AS ENUM (
    'script',
    'trigger',
    'failure',
    'command',
    'approval',
    'preprocessor'
);


--
-- Name: script_lang; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.script_lang AS ENUM (
    'python3',
    'deno',
    'go',
    'bash',
    'postgresql',
    'nativets',
    'bun',
    'mysql',
    'bigquery',
    'snowflake',
    'graphql',
    'powershell',
    'mssql',
    'php',
    'bunnative',
    'rust',
    'ansible',
    'csharp',
    'oracledb',
    'nu',
    'java',
    'duckdb',
    'ruby',
    'rlang',
    'dbt'
);


--
-- Name: script_trigger_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.script_trigger_kind AS ENUM (
    'asset',
    'schedule',
    'webhook',
    'email',
    'kafka',
    'mqtt',
    'nats',
    'postgres',
    'sqs',
    'gcp'
);


--
-- Name: trigger_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.trigger_kind AS ENUM (
    'webhook',
    'http',
    'websocket',
    'kafka',
    'email',
    'nats',
    'postgres',
    'sqs',
    'mqtt',
    'gcp',
    'default_email',
    'nextcloud',
    'google',
    'github',
    'azure',
    'amqp'
);


--
-- Name: trigger_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.trigger_mode AS ENUM (
    'enabled',
    'disabled',
    'suspended'
);


--
-- Name: workspace_key_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.workspace_key_kind AS ENUM (
    'cloud'
);


--
-- Name: audit_logs_s3_anchor_on_enable(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.audit_logs_s3_anchor_on_enable() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.value = to_jsonb(true)
       AND (TG_OP = 'INSERT' OR OLD.value IS DISTINCT FROM NEW.value) THEN
        INSERT INTO background_task_state (name, value)
        VALUES (
            'audit_logs_s3_export',
            jsonb_build_object(
                'last_xmin', txid_snapshot_xmin(txid_current_snapshot())::bigint,
                'last_ts', now(),
                'last_oldest_inflight_ts',
                    COALESCE(audit_logs_s3_oldest_inflight_ts(), now() - interval '7 days')
            )
        )
        ON CONFLICT (name) DO UPDATE
            SET value = EXCLUDED.value
            WHERE (background_task_state.value->>'last_xmin')::bigint
                  < (EXCLUDED.value->>'last_xmin')::bigint;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: audit_logs_s3_oldest_inflight_ts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.audit_logs_s3_oldest_inflight_ts() RETURNS timestamp with time zone
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_can_read_all_stats boolean := current_setting('is_superuser') = 'on';
BEGIN
    IF NOT v_can_read_all_stats THEN
        BEGIN
            v_can_read_all_stats := pg_has_role(current_user, 'pg_read_all_stats', 'USAGE');
        EXCEPTION WHEN OTHERS THEN
            v_can_read_all_stats := false;
        END;
    END IF;
    IF v_can_read_all_stats AND NOT EXISTS (SELECT 1 FROM pg_prepared_xacts) THEN
        RETURN (SELECT min(xact_start) FROM pg_stat_activity WHERE xact_start IS NOT NULL);
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: folder_labels(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.folder_labels(w_id text, item_path text) RETURNS text[]
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
    SELECT (
        SELECT array_agg(l ORDER BY first_ord)
        FROM (
            SELECT u.l, min(u.ord) AS first_ord
            FROM unnest(f.labels) WITH ORDINALITY AS u(l, ord)
            GROUP BY u.l
        ) deduped
    )
    FROM folder f
    WHERE f.workspace_id = w_id AND item_path LIKE 'f/%' AND f.name = split_part(item_path, '/', 2)
$$;


--
-- Name: list_ws_specific_versions(text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.list_ws_specific_versions(seed_workspace text, user_email text, item_kind text, item_path text) RETURNS TABLE(ws character varying)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    rel RECORD;
    usr_row RECORD;
    user_perms TEXT[];
    groups_csv TEXT;
    pgroups_csv TEXT;
    folders_read_csv TEXT;
    folders_write_csv TEXT;
    item_exists BOOLEAN;
    is_super BOOLEAN;
BEGIN
    IF item_kind NOT IN ('resource', 'variable') THEN
        RAISE EXCEPTION 'Invalid kind: %', item_kind;
    END IF;

    SELECT COALESCE(super_admin, false) INTO is_super
    FROM password WHERE email = user_email;
    is_super := COALESCE(is_super, false);

    BEGIN
        FOR rel IN
            WITH RECURSIVE related_workspaces(ws_id, depth, seen) AS (
                SELECT seed_workspace::VARCHAR, 0, ARRAY[seed_workspace::VARCHAR]
              UNION ALL
                SELECT step.next_id, r.depth + 1, r.seen || step.next_id
                FROM related_workspaces r
                CROSS JOIN LATERAL (
                    SELECT CASE WHEN w.id = r.ws_id THEN w.parent_workspace_id ELSE w.id END
                               AS next_id
                    FROM workspace w
                    WHERE (w.id = r.ws_id AND w.parent_workspace_id IS NOT NULL)
                       OR (w.parent_workspace_id = r.ws_id
                           AND w.is_dev_workspace AND NOT w.deleted)
                ) step
                -- The edges run both ways, so without this the walk bounces parent<->dev until it
                -- hits the depth cap on every call regardless of how few workspaces are related.
                WHERE r.depth < 32 AND NOT (step.next_id = ANY(r.seen))
            )
            SELECT DISTINCT r.ws_id
            FROM related_workspaces r
            INNER JOIN workspace w ON w.id = r.ws_id AND w.deleted = false
        LOOP
            SELECT u.username, u.is_admin
            INTO usr_row
            FROM usr u
            WHERE u.email = user_email
              AND u.workspace_id = rel.ws_id
              AND u.disabled = false;

            IF NOT FOUND AND NOT is_super THEN
                CONTINUE;
            END IF;

            IF NOT FOUND THEN
                -- super admin without a usr row in this workspace: synthesize an
                -- admin identity so RLS is bypassed (windmill_admin role).
                usr_row.username := user_email;
                usr_row.is_admin := true;
                groups_csv := '';
                pgroups_csv := '';
                folders_read_csv := '';
                folders_write_csv := '';
            ELSE
                SELECT
                    COALESCE(string_agg(g, ','), ''),
                    COALESCE(string_agg('g/' || g, ','), '')
                INTO groups_csv, pgroups_csv
                FROM (
                    SELECT group_ AS g FROM usr_to_group
                    WHERE usr_to_group.usr = usr_row.username
                      AND usr_to_group.workspace_id = rel.ws_id
                  UNION ALL
                    SELECT igroup FROM email_to_igroup WHERE email = user_email
                ) gs;

                user_perms := ARRAY['u/' || usr_row.username] || ARRAY(
                    SELECT 'g/' || g FROM (
                        SELECT group_ AS g FROM usr_to_group
                        WHERE usr = usr_row.username AND workspace_id = rel.ws_id
                      UNION ALL
                        SELECT igroup FROM email_to_igroup WHERE email = user_email
                    ) gs2
                );

                -- folders_read: every folder the user can see (write implies read);
                -- folders_write: only those granting write access.
                WITH user_folders AS (
                    SELECT name, EXISTS (
                        SELECT 1 FROM jsonb_each_text(extra_perms) t
                        WHERE t.key = ANY(user_perms) AND t.value::boolean IS true
                    ) AS is_write
                    FROM folder
                    WHERE extra_perms ?| user_perms AND folder.workspace_id = rel.ws_id
                )
                SELECT
                    COALESCE(string_agg(name, ','), ''),
                    COALESCE(string_agg(name, ',') FILTER (WHERE is_write), '')
                INTO folders_read_csv, folders_write_csv
                FROM user_folders;

                IF is_super THEN
                    usr_row.is_admin := true;
                END IF;
            END IF;

            PERFORM set_session_context(
                usr_row.is_admin,
                usr_row.username,
                groups_csv,
                pgroups_csv,
                folders_read_csv,
                folders_write_csv
            );

            EXECUTE format(
                'SELECT EXISTS(SELECT 1 FROM %I WHERE workspace_id = $1 AND path = $2)',
                item_kind
            )
            INTO item_exists
            USING rel.ws_id, item_path;

            IF item_exists THEN
                ws := rel.ws_id;
                RETURN NEXT;
            END IF;
        END LOOP;
    EXCEPTION WHEN OTHERS THEN
        -- Reset to a deny-default state before re-raising so a half-set
        -- session context can't leak past the failed call.
        PERFORM set_session_context(false, '', '', '', '', '');
        RAISE;
    END;

    -- Reset to a deny-default state on the happy path too. SET LOCAL is
    -- transaction-scoped so this also unwinds at transaction end, but
    -- being explicit defends against the function being called inside a
    -- longer outer transaction.
    PERFORM set_session_context(false, '', '', '', '', '');
END;
$_$;


--
-- Name: notify_app_policy_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_app_policy_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO notify_event (channel, payload)
    VALUES (
        'notify_app_policy_change',
        COALESCE(NEW.workspace_id, OLD.workspace_id) || ':' || COALESCE(NEW.path, OLD.path)
    );
    RETURN COALESCE(NEW, OLD);
END;
$$;


--
-- Name: notify_config_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_config_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO notify_event (channel, payload) VALUES ('notify_config_change', NEW.name::text);
    RETURN NEW;
END;
$$;


--
-- Name: notify_global_setting_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_global_setting_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO notify_event (channel, payload) VALUES ('notify_global_setting_change', NEW.name::text);
    RETURN NEW;
END;
$$;


--
-- Name: notify_global_setting_delete(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_global_setting_delete() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO notify_event (channel, payload) VALUES ('notify_global_setting_change', OLD.name::text);
    RETURN OLD;
END;
$$;


--
-- Name: notify_http_trigger_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_http_trigger_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO notify_event (channel, payload) VALUES ('notify_http_trigger_change', COALESCE(NEW.workspace_id, OLD.workspace_id) || ':' || COALESCE(NEW.path, OLD.path));
    RETURN COALESCE(NEW, OLD);
END;
$$;


--
-- Name: notify_runnable_version_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_runnable_version_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    source_type TEXT;
    kind TEXT;
BEGIN
    source_type := TG_ARGV[0];

    IF source_type = 'script' THEN
        kind := NEW.kind;
    ELSE
        kind := 'flow';
    END IF;

    INSERT INTO notify_event (channel, payload) VALUES ('notify_runnable_version_change', NEW.workspace_id || ':' || source_type || ':' || NEW.path || ':' || kind);
    RETURN NEW;
END;
$$;


--
-- Name: notify_team_plan_status_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_team_plan_status_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO notify_event (channel, payload) VALUES ('notify_workspace_premium_change', NEW.workspace_id);
    RETURN NEW;
END;
$$;


--
-- Name: notify_token_invalidation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_token_invalidation() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    IF OLD.label = 'session' AND OLD.email IS NOT NULL THEN
        INSERT INTO notify_event (channel, payload)
        VALUES ('notify_token_invalidation', OLD.token_prefix);
    END IF;
    RETURN OLD;
END;
$$;


--
-- Name: notify_token_scopes_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_token_scopes_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    IF OLD.scopes IS DISTINCT FROM NEW.scopes THEN
        INSERT INTO notify_event (channel, payload)
        VALUES ('notify_token_invalidation', NEW.token_prefix);
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: notify_webhook_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_webhook_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO notify_event (channel, payload) VALUES ('notify_webhook_change', NEW.workspace_id);
    RETURN NEW;
END;
$$;


--
-- Name: notify_workspace_envs_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_workspace_envs_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO notify_event (channel, payload) VALUES ('notify_workspace_envs_change', COALESCE(NEW.workspace_id, OLD.workspace_id));
    RETURN COALESCE(NEW, OLD);
END;
$$;


--
-- Name: notify_workspace_key_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_workspace_key_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO notify_event (channel, payload) VALUES ('notify_workspace_key_change', OLD.workspace_id);
        RETURN OLD;
    ELSE
        INSERT INTO notify_event (channel, payload) VALUES ('notify_workspace_key_change', NEW.workspace_id);
        RETURN NEW;
    END IF;
END;
$$;


--
-- Name: notify_workspace_premium_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_workspace_premium_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO notify_event (channel, payload) VALUES ('notify_workspace_premium_change', NEW.id);
    RETURN NEW;
END;
$$;


--
-- Name: notify_workspace_rate_limit_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_workspace_rate_limit_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO notify_event (channel, payload)
    VALUES ('notify_workspace_rate_limit_change', NEW.workspace_id);
    RETURN NEW;
END;
$$;


--
-- Name: prevent_route_path_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.prevent_route_path_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF CURRENT_USER = 'windmill_user' AND NEW.route_path <> OLD.route_path AND NOT COALESCE(NEW.workspaced_route, false) THEN
        RAISE EXCEPTION 'Modification of route_path is only allowed by admins for non-workspaced routes';
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: record_resource_version(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.record_resource_version() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
BEGIN
    -- `session.user` is set by UserDB::begin for authed requests; worker and system writes fall
    -- back to the row's own author. NULLIF because a transaction-local set_config resets the
    -- placeholder to the empty string rather than unsetting it, so a pooled connection that
    -- previously served an authed request reports '' here, not NULL.
    INSERT INTO resource_version (workspace_id, path, resource_type, value, created_by)
    VALUES (
        NEW.workspace_id, NEW.path, NEW.resource_type, NEW.value,
        COALESCE(NULLIF(current_setting('session.user', true), ''), NEW.created_by)
    );

    -- The per-path cap is enforced by trim_resource_versions in the monitor, not here: trimming
    -- on every write would tax a path `setResource` can drive in a loop, to keep a bound that
    -- does not need to hold instantaneously.

    RETURN NEW;
END;
-- SECURITY DEFINER so history is written on behalf of every writer, including the read-only
-- policy above, without granting anyone direct write access to the table. `SET search_path FROM
-- CURRENT` is the injection hardening that goes with it, captured rather than hardcoded so
-- installs running a non-public PG_SCHEMA still resolve (see
-- 20260624103600_repair_folder_labels_search_path.up.sql).
$$;


--
-- Name: set_session_context(boolean, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_session_context(admin boolean, username text, groups text, pgroups text, folders_read text, folders_write text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF admin THEN
        SET LOCAL ROLE windmill_admin;
    ELSE
        SET LOCAL ROLE windmill_user;
    END IF;
    PERFORM set_config('session.user', username, true);
    PERFORM set_config('session.groups', groups, true);
    PERFORM set_config('session.pgroups', pgroups, true);
    PERFORM set_config('session.folders_read', folders_read, true);
    PERFORM set_config('session.folders_write', folders_write, true);
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _sqlx_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._sqlx_migrations (
    version bigint NOT NULL,
    description text NOT NULL,
    installed_on timestamp with time zone DEFAULT now() NOT NULL,
    success boolean NOT NULL,
    checksum bytea NOT NULL,
    execution_time bigint NOT NULL
);


--
-- Name: account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account (
    workspace_id character varying(50) NOT NULL,
    id integer NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    refresh_token character varying(10000) NOT NULL,
    client character varying(50) NOT NULL,
    refresh_error text,
    grant_type character varying(50) DEFAULT 'authorization_code'::character varying NOT NULL,
    cc_client_id character varying(500),
    cc_client_secret character varying(500),
    cc_token_url character varying(500),
    mcp_server_url text,
    is_workspace_integration boolean DEFAULT false NOT NULL,
    scopes text[]
);


--
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_id_seq OWNED BY public.account.id;


--
-- Name: agent_token_blacklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_token_blacklist (
    token character varying NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    blacklisted_at timestamp without time zone DEFAULT now() NOT NULL,
    blacklisted_by character varying NOT NULL
);


--
-- Name: ai_agent_memory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_agent_memory (
    workspace_id character varying(50) NOT NULL,
    conversation_id uuid NOT NULL,
    step_id character varying(255) NOT NULL,
    messages jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_skill; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_skill (
    workspace_id character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    instructions text NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    edited_by character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alerts (
    id integer NOT NULL,
    alert_type character varying(50) NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    acknowledged boolean,
    workspace_id text,
    acknowledged_workspace boolean,
    resource text
);


--
-- Name: alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alerts_id_seq OWNED BY public.alerts.id;


--
-- Name: amqp_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.amqp_trigger (
    amqp_resource_path character varying(255) NOT NULL,
    queue_name character varying(255) NOT NULL,
    exchange jsonb,
    options jsonb,
    path character varying(255) NOT NULL,
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    server_id character varying(50),
    last_server_ping timestamp with time zone,
    error text,
    error_handler_path character varying(255),
    error_handler_args jsonb,
    retry jsonb,
    mode public.trigger_mode DEFAULT 'enabled'::public.trigger_mode NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    labels text[]
);


--
-- Name: app; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app (
    id bigint NOT NULL,
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    summary character varying(1000) DEFAULT ''::character varying NOT NULL,
    policy jsonb NOT NULL,
    versions bigint[] NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    custom_path text,
    labels text[],
    CONSTRAINT app_custom_path_check CHECK ((custom_path ~ '^[\w-]+(\/[\w-]+)*$'::text))
);


--
-- Name: app_bundles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_bundles (
    app_version_id bigint NOT NULL,
    w_id character varying(255) NOT NULL,
    file_type character varying(10) NOT NULL,
    data bytea NOT NULL
);


--
-- Name: app_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.app_id_seq OWNED BY public.app.id;


--
-- Name: app_script; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_script (
    id bigint NOT NULL,
    app bigint NOT NULL,
    hash character(64) NOT NULL,
    lock text,
    code text NOT NULL,
    code_sha256 character(64) NOT NULL
);


--
-- Name: app_script_app_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.app_script_app_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_script_app_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.app_script_app_seq OWNED BY public.app_script.app;


--
-- Name: app_script_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.app_script_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_script_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.app_script_id_seq OWNED BY public.app_script.id;


--
-- Name: app_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_version (
    id bigint NOT NULL,
    app_id bigint NOT NULL,
    value json NOT NULL,
    created_by character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    raw_app boolean DEFAULT false NOT NULL
);


--
-- Name: app_version_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.app_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.app_version_id_seq OWNED BY public.app_version.id;


--
-- Name: app_version_lite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_version_lite (
    id bigint NOT NULL,
    value jsonb
);


--
-- Name: app_version_lite_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.app_version_lite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_version_lite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.app_version_lite_id_seq OWNED BY public.app_version_lite.id;


--
-- Name: asset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset (
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    kind public.asset_kind NOT NULL,
    usage_access_type public.asset_access_type,
    usage_path character varying(255) NOT NULL,
    usage_kind public.asset_usage_kind NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    columns jsonb
);


--
-- Name: asset_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asset_id_seq OWNED BY public.asset.id;


--
-- Name: audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit (
    workspace_id character varying(50) NOT NULL,
    id bigint NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    username character varying(255) NOT NULL,
    operation character varying(50) NOT NULL,
    action_kind public.action_kind NOT NULL,
    resource character varying(255),
    parameters jsonb,
    email character varying(255),
    span character varying(255)
);


--
-- Name: audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_id_seq OWNED BY public.audit.id;


--
-- Name: audit_partitioned; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_partitioned (
    workspace_id character varying(50) NOT NULL,
    id bigint DEFAULT nextval('public.audit_id_seq'::regclass) NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    username character varying(255) NOT NULL,
    operation character varying(50) NOT NULL,
    action_kind public.action_kind NOT NULL,
    resource character varying(255),
    parameters jsonb,
    email character varying(255),
    span character varying(255)
)
PARTITION BY RANGE ("timestamp");


--
-- Name: audit_20260815; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_20260815 (
    workspace_id character varying(50) NOT NULL,
    id bigint DEFAULT nextval('public.audit_id_seq'::regclass) NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    username character varying(255) NOT NULL,
    operation character varying(50) NOT NULL,
    action_kind public.action_kind NOT NULL,
    resource character varying(255),
    parameters jsonb,
    email character varying(255),
    span character varying(255)
);


--
-- Name: audit_20260816; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_20260816 (
    workspace_id character varying(50) NOT NULL,
    id bigint DEFAULT nextval('public.audit_id_seq'::regclass) NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    username character varying(255) NOT NULL,
    operation character varying(50) NOT NULL,
    action_kind public.action_kind NOT NULL,
    resource character varying(255),
    parameters jsonb,
    email character varying(255),
    span character varying(255)
);


--
-- Name: audit_20260817; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_20260817 (
    workspace_id character varying(50) NOT NULL,
    id bigint DEFAULT nextval('public.audit_id_seq'::regclass) NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    username character varying(255) NOT NULL,
    operation character varying(50) NOT NULL,
    action_kind public.action_kind NOT NULL,
    resource character varying(255),
    parameters jsonb,
    email character varying(255),
    span character varying(255)
);


--
-- Name: audit_20260818; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_20260818 (
    workspace_id character varying(50) NOT NULL,
    id bigint DEFAULT nextval('public.audit_id_seq'::regclass) NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    username character varying(255) NOT NULL,
    operation character varying(50) NOT NULL,
    action_kind public.action_kind NOT NULL,
    resource character varying(255),
    parameters jsonb,
    email character varying(255),
    span character varying(255)
);


--
-- Name: autoscaling_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.autoscaling_event (
    id integer NOT NULL,
    worker_group text NOT NULL,
    event_type public.autoscaling_event_type NOT NULL,
    desired_workers integer NOT NULL,
    applied_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    reason text
);


--
-- Name: autoscaling_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.autoscaling_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autoscaling_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.autoscaling_event_id_seq OWNED BY public.autoscaling_event.id;


--
-- Name: azure_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.azure_trigger (
    azure_resource_path character varying(255) NOT NULL,
    azure_mode public.azure_trigger_mode NOT NULL,
    scope_resource_id text NOT NULL,
    topic_name character varying(255),
    subscription_name character varying(255) NOT NULL,
    event_type_filters jsonb,
    push_auth_config jsonb,
    path character varying(255) NOT NULL,
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    server_id character varying(50),
    last_server_ping timestamp with time zone,
    error text,
    mode public.trigger_mode DEFAULT 'enabled'::public.trigger_mode NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    error_handler_path character varying(255),
    error_handler_args jsonb,
    retry jsonb,
    labels text[],
    CONSTRAINT azure_push_auth_config_matches_mode CHECK ((((azure_mode = ANY (ARRAY['basic_push'::public.azure_trigger_mode, 'namespace_push'::public.azure_trigger_mode])) AND (push_auth_config IS NOT NULL)) OR ((azure_mode = 'namespace_pull'::public.azure_trigger_mode) AND (push_auth_config IS NULL)))),
    CONSTRAINT azure_topic_name_matches_mode CHECK ((((azure_mode = 'basic_push'::public.azure_trigger_mode) AND (topic_name IS NULL)) OR ((azure_mode = ANY (ARRAY['namespace_push'::public.azure_trigger_mode, 'namespace_pull'::public.azure_trigger_mode])) AND (topic_name IS NOT NULL))))
);


--
-- Name: background_task_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.background_task_state (
    name text NOT NULL,
    value jsonb NOT NULL,
    running boolean DEFAULT false NOT NULL,
    owner text,
    started_at timestamp with time zone,
    finished_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: capture; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.capture (
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(50) NOT NULL,
    main_args jsonb DEFAULT 'null'::jsonb NOT NULL,
    is_flow boolean NOT NULL,
    trigger_kind public.trigger_kind NOT NULL,
    preprocessor_args jsonb,
    id bigint NOT NULL,
    CONSTRAINT capture_payload_too_big CHECK ((length((main_args)::text) < (512 * 1024)))
);


--
-- Name: capture_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.capture_config (
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    trigger_kind public.trigger_kind NOT NULL,
    trigger_config jsonb,
    owner character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    server_id character varying(50),
    last_client_ping timestamp with time zone,
    last_server_ping timestamp with time zone,
    error text
);


--
-- Name: capture_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.capture ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.capture_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ci_test_reference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ci_test_reference (
    workspace_id character varying(50) NOT NULL,
    test_script_path character varying(510) NOT NULL,
    test_script_hash bigint NOT NULL,
    tested_item_path character varying(510) NOT NULL,
    tested_item_kind character varying(10) NOT NULL,
    has_wildcard boolean GENERATED ALWAYS AS (((tested_item_path)::text ~~ '%*%'::text)) STORED
);


--
-- Name: cloud_workspace_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cloud_workspace_settings (
    workspace_id character varying(50) NOT NULL,
    threshold_alert_amount integer,
    last_alert_sent timestamp without time zone,
    last_warning_sent timestamp without time zone,
    is_past_due boolean DEFAULT false NOT NULL,
    max_tolerated_executions integer
);


--
-- Name: concurrency_counter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.concurrency_counter (
    concurrency_id character varying(1000) NOT NULL,
    job_uuids jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: concurrency_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.concurrency_key (
    key character varying(255) NOT NULL,
    ended_at timestamp with time zone,
    job_id uuid NOT NULL
);


--
-- Name: concurrency_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.concurrency_locks (
    id character varying NOT NULL,
    last_locked_at timestamp without time zone NOT NULL,
    owner character varying
);


--
-- Name: concurrency_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.concurrency_settings (
    hash bigint NOT NULL,
    concurrency_key character varying(255),
    concurrent_limit integer,
    concurrency_time_window_s integer
);


--
-- Name: config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.config (
    name character varying(255) NOT NULL,
    config jsonb DEFAULT '{}'::jsonb
);


--
-- Name: custom_concurrency_key_ended; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_concurrency_key_ended (
    key character varying(255) NOT NULL,
    ended_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: data_metric; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_metric (
    workspace_id character varying(50) NOT NULL,
    script_path character varying(510) NOT NULL,
    table_path character varying(510) NOT NULL,
    kind character varying(16) NOT NULL,
    name character varying(255) NOT NULL,
    expr text NOT NULL,
    filter text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT data_metric_kind_check CHECK (((kind)::text = ANY ((ARRAY['measure'::character varying, 'dimension'::character varying])::text[])))
);


--
-- Name: datatable_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datatable_migrations (
    workspace_id character varying(50) NOT NULL,
    datatable character varying(255) NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying(255) NOT NULL,
    code_up text NOT NULL,
    code_down text
);


--
-- Name: dbt_edge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dbt_edge (
    workspace_id character varying(50) NOT NULL,
    script_path character varying(255) NOT NULL,
    script_hash bigint,
    job_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    parent_unique_id text NOT NULL,
    child_unique_id text NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: dbt_graph_snapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dbt_graph_snapshot (
    workspace_id character varying(50) NOT NULL,
    script_path character varying(255) NOT NULL,
    script_hash bigint,
    job_id uuid NOT NULL,
    digest text NOT NULL,
    relation_root_at_last_ingest text,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    permissioned_as character varying(255)
);


--
-- Name: dbt_node; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dbt_node (
    workspace_id character varying(50) NOT NULL,
    script_path character varying(255) NOT NULL,
    script_hash bigint,
    job_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    unique_id text NOT NULL,
    resource_type text NOT NULL,
    name text NOT NULL,
    asset_path text,
    materialized text,
    materialize_strategy text,
    unique_key text,
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    description text,
    test_kind text,
    test_column text,
    test_args jsonb,
    severity text,
    attached_node text,
    columns jsonb,
    freshness jsonb,
    raw_code text,
    original_file_path text,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: dbt_run_progress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dbt_run_progress (
    workspace_id character varying(50) NOT NULL,
    job_id uuid NOT NULL,
    asset_kind public.asset_kind NOT NULL,
    asset_path character varying(255) NOT NULL,
    status public.materialization_status NOT NULL,
    row_count bigint,
    error text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: dbt_run_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dbt_run_state (
    workspace_id character varying(50) NOT NULL,
    script_path character varying(255) NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    identity text NOT NULL,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    run_results text NOT NULL,
    job_id uuid,
    retryable boolean DEFAULT false NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: debounce_batch_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.debounce_batch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: debounce_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debounce_key (
    key character varying(255) NOT NULL,
    job_id uuid NOT NULL,
    previous_job_id uuid,
    first_started_at timestamp with time zone DEFAULT now() NOT NULL,
    debounced_times integer DEFAULT 0 NOT NULL
);


--
-- Name: debounce_stale_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debounce_stale_data (
    job_id uuid NOT NULL,
    to_relock text[]
);


--
-- Name: debouncing_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debouncing_settings (
    hash bigint NOT NULL,
    debounce_key character varying(255),
    debounce_delay_s integer,
    max_total_debouncing_time integer,
    max_total_debounces_amount integer,
    debounce_args_to_accumulate text[]
);


--
-- Name: dependency_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dependency_map (
    workspace_id character varying(50) NOT NULL,
    importer_path character varying(510) NOT NULL,
    importer_kind public.importer_kind NOT NULL,
    imported_path character varying(510) NOT NULL,
    importer_node_id character varying(255) DEFAULT ''::character varying NOT NULL,
    imported_lockfile_hash bigint
);


--
-- Name: deployment_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deployment_metadata (
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    script_hash bigint,
    app_version bigint,
    callback_job_ids uuid[],
    deployment_msg text,
    flow_version bigint,
    job_id uuid
);


--
-- Name: dispatch_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dispatch_event (
    id bigint NOT NULL,
    workspace_id character varying(50) NOT NULL,
    producer_job_id uuid NOT NULL,
    subscriber_path character varying(255) NOT NULL,
    asset_kind public.asset_kind NOT NULL,
    asset_path text NOT NULL,
    outcome public.dispatch_outcome NOT NULL,
    child_job_id uuid,
    partition text,
    received_inputs integer,
    required_inputs integer,
    debounce_s integer,
    reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: dispatch_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dispatch_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dispatch_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dispatch_event_id_seq OWNED BY public.dispatch_event.id;


--
-- Name: draft; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.draft (
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    typ public.draft_kind NOT NULL,
    value json NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    email character varying(255),
    id bigint NOT NULL
);


--
-- Name: draft_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.draft_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: draft_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.draft_id_seq OWNED BY public.draft.id;


--
-- Name: email_to_igroup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_to_igroup (
    email character varying(255) NOT NULL,
    igroup character varying(255) NOT NULL
);


--
-- Name: email_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_trigger (
    path character varying(255) NOT NULL,
    local_part character varying(255) NOT NULL,
    workspaced_local_part boolean NOT NULL,
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    error_handler_path character varying(255),
    error_handler_args jsonb,
    retry jsonb,
    mode public.trigger_mode DEFAULT 'enabled'::public.trigger_mode NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    labels text[]
);


--
-- Name: favorite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorite (
    usr character varying(50) NOT NULL,
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    favorite_kind public.favorite_kind NOT NULL
);


--
-- Name: feature_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feature_usage (
    feature character varying(50) NOT NULL,
    kind character varying(50) NOT NULL,
    key character varying(100) DEFAULT ''::character varying NOT NULL,
    entity_id character varying(50) DEFAULT ''::character varying NOT NULL,
    day date DEFAULT CURRENT_DATE NOT NULL,
    value bigint DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: flow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flow (
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    summary text NOT NULL,
    description text NOT NULL,
    value jsonb NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    schema json,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    dependency_job uuid,
    tag character varying(50),
    ws_error_handler_muted boolean DEFAULT false NOT NULL,
    dedicated_worker boolean,
    timeout integer,
    visible_to_runner_only boolean,
    concurrency_key character varying(255),
    versions bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    on_behalf_of_email text,
    lock_error_logs text,
    labels text[],
    on_behalf_of character varying(255),
    CONSTRAINT proper_id CHECK (((path)::text ~ '^[ufg](\/[\w-]+){2,}$'::text))
);


--
-- Name: flow_conversation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flow_conversation (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id character varying(50) NOT NULL,
    flow_path character varying(255) NOT NULL,
    title character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(50) NOT NULL
);


--
-- Name: flow_conversation_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flow_conversation_message (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id uuid NOT NULL,
    message_type public.message_type NOT NULL,
    content text NOT NULL,
    job_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    step_name character varying(255),
    success boolean DEFAULT true NOT NULL,
    created_seq bigint NOT NULL
);


--
-- Name: flow_conversation_message_created_seq_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.flow_conversation_message ALTER COLUMN created_seq ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.flow_conversation_message_created_seq_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: flow_iterator_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flow_iterator_data (
    job_id uuid NOT NULL,
    itered jsonb NOT NULL
);


--
-- Name: flow_node_hash_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flow_node_hash_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flow_node; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flow_node (
    id bigint NOT NULL,
    workspace_id character varying(50) NOT NULL,
    hash bigint,
    path character varying(255) NOT NULL,
    lock text,
    code text,
    flow jsonb,
    hash_v2 character(64) DEFAULT to_hex(nextval('public.flow_node_hash_seq'::regclass)) NOT NULL
);


--
-- Name: flow_node_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flow_node_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flow_node_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flow_node_id_seq OWNED BY public.flow_node.id;


--
-- Name: flow_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flow_version (
    id bigint NOT NULL,
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    value jsonb NOT NULL,
    schema json,
    created_by character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: flow_version_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flow_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flow_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flow_version_id_seq OWNED BY public.flow_version.id;


--
-- Name: flow_version_lite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flow_version_lite (
    id bigint NOT NULL,
    value jsonb
);


--
-- Name: flow_version_lite_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flow_version_lite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flow_version_lite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flow_version_lite_id_seq OWNED BY public.flow_version_lite.id;


--
-- Name: workspace_runnable_dependencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_runnable_dependencies (
    flow_path character varying(255),
    runnable_path character varying(255) NOT NULL,
    script_hash bigint,
    runnable_is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    app_path character varying(255),
    CONSTRAINT workspace_runnable_dependencies_path_exclusive CHECK ((((flow_path IS NOT NULL) AND (app_path IS NULL)) OR ((flow_path IS NULL) AND (app_path IS NOT NULL))))
);


--
-- Name: flow_workspace_runnables; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.flow_workspace_runnables AS
 SELECT flow_path,
    runnable_path,
    script_hash,
    runnable_is_flow,
    workspace_id
   FROM public.workspace_runnable_dependencies;


--
-- Name: folder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.folder (
    name character varying(255) NOT NULL,
    workspace_id character varying(50) NOT NULL,
    display_name character varying(100) NOT NULL,
    owners character varying(255)[] NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    summary text,
    edited_at timestamp with time zone,
    created_by character varying(50),
    default_permissioned_as jsonb DEFAULT '[]'::jsonb NOT NULL,
    labels text[]
);


--
-- Name: folder_permission_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.folder_permission_history (
    id bigint NOT NULL,
    workspace_id character varying(50) NOT NULL,
    folder_name character varying(255) NOT NULL,
    changed_by character varying(50) NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    change_type character varying(50) NOT NULL,
    affected character varying(100)
);


--
-- Name: folder_permission_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.folder_permission_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: folder_permission_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.folder_permission_history_id_seq OWNED BY public.folder_permission_history.id;


--
-- Name: fork_ducklake_namespace; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fork_ducklake_namespace (
    workspace_id character varying(50) NOT NULL,
    ducklake_name character varying(255) NOT NULL,
    metadata_schema character varying(63) NOT NULL,
    catalog text NOT NULL,
    storage text DEFAULT ''::text NOT NULL,
    storage_ref text DEFAULT ''::text NOT NULL,
    data_path text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    schema_dropped boolean DEFAULT false NOT NULL
);


--
-- Name: gcp_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gcp_trigger (
    gcp_resource_path character varying(255) NOT NULL,
    topic_id character varying(255) NOT NULL,
    subscription_id character varying(255) NOT NULL,
    delivery_type public.delivery_mode NOT NULL,
    delivery_config jsonb,
    path character varying(255) NOT NULL,
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    server_id character varying(50),
    last_server_ping timestamp with time zone,
    error text,
    subscription_mode public.gcp_subscription_mode DEFAULT 'create_update'::public.gcp_subscription_mode NOT NULL,
    error_handler_path character varying(255),
    error_handler_args jsonb,
    retry jsonb,
    auto_acknowledge_msg boolean DEFAULT true,
    ack_deadline integer,
    mode public.trigger_mode DEFAULT 'enabled'::public.trigger_mode NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    labels text[],
    CONSTRAINT gcp_trigger_check CHECK (((delivery_type <> 'push'::public.delivery_mode) OR (delivery_config IS NOT NULL))),
    CONSTRAINT gcp_trigger_subscription_id_check CHECK (((char_length((subscription_id)::text) >= 3) AND (char_length((subscription_id)::text) <= 255))),
    CONSTRAINT gcp_trigger_topic_id_check CHECK (((char_length((topic_id)::text) >= 3) AND (char_length((topic_id)::text) <= 255)))
);


--
-- Name: global_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.global_settings (
    name character varying(255) NOT NULL,
    value jsonb NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: group_; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_ (
    workspace_id character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    summary text,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT proper_name CHECK (((name)::text ~ '^[\w-]+$'::text))
);


--
-- Name: group_permission_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_permission_history (
    id bigint NOT NULL,
    workspace_id character varying(50) NOT NULL,
    group_name character varying(255) NOT NULL,
    changed_by character varying(50) NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    change_type character varying(50) NOT NULL,
    member_affected character varying(100)
);


--
-- Name: group_permission_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_permission_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_permission_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_permission_history_id_seq OWNED BY public.group_permission_history.id;


--
-- Name: healthchecks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.healthchecks (
    id bigint NOT NULL,
    check_type text NOT NULL,
    healthy boolean NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: healthchecks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.healthchecks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: healthchecks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.healthchecks_id_seq OWNED BY public.healthchecks.id;


--
-- Name: http_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.http_trigger (
    path character varying(255) NOT NULL,
    route_path character varying(255) NOT NULL,
    route_path_key character varying(255) NOT NULL,
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    authentication_method public.authentication_method DEFAULT 'none'::public.authentication_method NOT NULL,
    http_method public.http_method NOT NULL,
    static_asset_config jsonb,
    is_static_website boolean DEFAULT false NOT NULL,
    workspaced_route boolean DEFAULT false NOT NULL,
    wrap_body boolean DEFAULT false NOT NULL,
    raw_string boolean DEFAULT false NOT NULL,
    authentication_resource_path character varying(255) DEFAULT NULL::character varying,
    summary character varying(512),
    description text,
    error_handler_path character varying(255),
    error_handler_args jsonb,
    retry jsonb,
    request_type public.request_type DEFAULT 'sync'::public.request_type NOT NULL,
    mode public.trigger_mode DEFAULT 'enabled'::public.trigger_mode NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    labels text[]
);


--
-- Name: http_trigger_version_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.http_trigger_version_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: input; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.input (
    id uuid NOT NULL,
    workspace_id character varying(50) NOT NULL,
    runnable_id character varying(255) NOT NULL,
    runnable_type public.runnable_type NOT NULL,
    name text NOT NULL,
    args jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(50) NOT NULL,
    is_public boolean DEFAULT false NOT NULL
);


--
-- Name: instance_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instance_group (
    name character varying(255) NOT NULL,
    summary character varying(2000),
    id character varying(1000),
    scim_display_name character varying(255),
    external_id character varying(512),
    instance_role character varying(20) DEFAULT NULL::character varying,
    CONSTRAINT check_instance_role CHECK (((instance_role)::text = ANY ((ARRAY['devops'::character varying, 'superadmin'::character varying])::text[])))
);


--
-- Name: job_delete_schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_delete_schedule (
    job_id uuid NOT NULL,
    workspace_id character varying(50) NOT NULL,
    delete_at timestamp with time zone NOT NULL
);


--
-- Name: job_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_logs (
    job_id uuid NOT NULL,
    workspace_id character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    logs text,
    log_offset integer DEFAULT 0 NOT NULL,
    log_file_index text[]
);


--
-- Name: job_perms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_perms (
    job_id uuid NOT NULL,
    email character varying(255) NOT NULL,
    username character varying(50) NOT NULL,
    is_admin boolean NOT NULL,
    is_operator boolean NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    workspace_id character varying(50) NOT NULL,
    groups text[] NOT NULL,
    folders jsonb[] NOT NULL,
    end_user_email character varying(255)
);


--
-- Name: job_resolution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_resolution (
    job_id uuid NOT NULL,
    workspace_id character varying(50) NOT NULL,
    resolved_at timestamp with time zone DEFAULT now() NOT NULL,
    resolved_by character varying(255),
    note text,
    automatic boolean DEFAULT false NOT NULL
);


--
-- Name: job_result_stream; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_result_stream (
    job_id uuid NOT NULL,
    workspace_id text NOT NULL,
    stream text NOT NULL
);


--
-- Name: job_result_stream_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_result_stream_v2 (
    job_id uuid NOT NULL,
    workspace_id text NOT NULL,
    stream text NOT NULL,
    idx integer NOT NULL
);


--
-- Name: job_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_settings (
    job_id uuid NOT NULL,
    runnable_settings bigint
);


--
-- Name: job_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_stats (
    workspace_id character varying(50) NOT NULL,
    job_id uuid NOT NULL,
    metric_id character varying(50) NOT NULL,
    metric_name character varying(255),
    metric_kind public.metric_kind NOT NULL,
    scalar_int integer,
    scalar_float real,
    timestamps timestamp with time zone[],
    timeseries_int integer[],
    timeseries_float real[],
    timeseries_start timestamp with time zone,
    offsets_cs integer[]
);


--
-- Name: join_pending_inputs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.join_pending_inputs (
    workspace_id character varying(50) NOT NULL,
    subscriber_path character varying(255) NOT NULL,
    partition text NOT NULL,
    trigger_ref text NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: kafka_pending_commits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kafka_pending_commits (
    id bigint NOT NULL,
    workspace_id character varying(50) NOT NULL,
    kafka_trigger_path character varying(255) NOT NULL,
    topic character varying(255) NOT NULL,
    partition integer NOT NULL,
    "offset" bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: kafka_pending_commits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kafka_pending_commits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kafka_pending_commits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kafka_pending_commits_id_seq OWNED BY public.kafka_pending_commits.id;


--
-- Name: kafka_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kafka_trigger (
    path character varying(255) NOT NULL,
    kafka_resource_path character varying(255) NOT NULL,
    topics character varying(255)[] NOT NULL,
    group_id character varying(255) NOT NULL,
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    server_id character varying(50),
    last_server_ping timestamp with time zone,
    error text,
    error_handler_path character varying(255),
    error_handler_args jsonb,
    retry jsonb,
    mode public.trigger_mode DEFAULT 'enabled'::public.trigger_mode NOT NULL,
    filters jsonb[] DEFAULT '{}'::jsonb[] NOT NULL,
    auto_offset_reset character varying(10) DEFAULT 'latest'::character varying NOT NULL,
    reset_offset boolean DEFAULT false NOT NULL,
    auto_commit boolean DEFAULT true NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    filter_logic character varying(3) DEFAULT 'and'::character varying NOT NULL,
    labels text[]
);


--
-- Name: lock_hash; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lock_hash (
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    lockfile_hash bigint NOT NULL
);


--
-- Name: log_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.log_file (
    hostname character varying(255) NOT NULL,
    log_ts timestamp without time zone NOT NULL,
    ok_lines bigint,
    err_lines bigint,
    mode public.log_mode NOT NULL,
    worker_group character varying(255),
    file_path character varying(510) NOT NULL,
    json_fmt boolean DEFAULT false
);


--
-- Name: macro_definition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.macro_definition (
    workspace_id character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    provider_path character varying(510) NOT NULL,
    params text NOT NULL,
    body text NOT NULL,
    is_table_macro boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: macro_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.macro_usage (
    workspace_id character varying(50) NOT NULL,
    consumer_path character varying(510) NOT NULL,
    macro_name character varying(255) NOT NULL
);


--
-- Name: magic_link; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.magic_link (
    email character varying(255) NOT NULL,
    token character varying(100) NOT NULL,
    expiration timestamp with time zone DEFAULT (now() + '1 day'::interval) NOT NULL
);


--
-- Name: materialized_asset_schema; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.materialized_asset_schema (
    workspace_id character varying(50) NOT NULL,
    asset_kind public.asset_kind NOT NULL,
    asset_path character varying(255) NOT NULL,
    version bigint NOT NULL,
    columns jsonb NOT NULL,
    snapshot_id bigint,
    job_id uuid,
    captured_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: materialized_partition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.materialized_partition (
    workspace_id character varying(50) NOT NULL,
    asset_kind public.asset_kind NOT NULL,
    asset_path character varying(255) NOT NULL,
    partition text DEFAULT ''::text NOT NULL,
    status public.materialization_status NOT NULL,
    snapshot_id bigint,
    row_count bigint,
    job_id uuid,
    materialized_at timestamp with time zone DEFAULT now() NOT NULL,
    error text
);


--
-- Name: mcp_oauth_client; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mcp_oauth_client (
    mcp_server_url text NOT NULL,
    client_id text NOT NULL,
    client_secret text,
    client_secret_expires_at timestamp without time zone,
    token_endpoint text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: mcp_oauth_refresh_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mcp_oauth_refresh_token (
    id bigint NOT NULL,
    refresh_token character varying(64) NOT NULL,
    access_token_hash character varying(64) NOT NULL,
    client_id character varying(255) NOT NULL,
    user_email character varying(255) NOT NULL,
    workspace_id character varying(50) NOT NULL,
    scopes text[] NOT NULL,
    token_family uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    revoked boolean DEFAULT false NOT NULL
);


--
-- Name: mcp_oauth_refresh_token_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mcp_oauth_refresh_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mcp_oauth_refresh_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mcp_oauth_refresh_token_id_seq OWNED BY public.mcp_oauth_refresh_token.id;


--
-- Name: mcp_oauth_server_client; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mcp_oauth_server_client (
    client_id character varying(255) NOT NULL,
    client_name character varying(255) NOT NULL,
    redirect_uris text[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mcp_oauth_server_code; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mcp_oauth_server_code (
    code character varying(64) NOT NULL,
    client_id character varying(255) NOT NULL,
    user_email character varying(255) NOT NULL,
    workspace_id character varying(50) NOT NULL,
    scopes text[] NOT NULL,
    redirect_uri text NOT NULL,
    code_challenge character varying(128),
    code_challenge_method character varying(10),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:10:00'::interval) NOT NULL
);


--
-- Name: metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metrics (
    id character varying(255) NOT NULL,
    value jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: mqtt_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mqtt_trigger (
    mqtt_resource_path character varying(255) NOT NULL,
    subscribe_topics jsonb[] NOT NULL,
    client_version public.mqtt_client_version DEFAULT 'v5'::public.mqtt_client_version NOT NULL,
    v5_config jsonb,
    v3_config jsonb,
    client_id character varying(65535) DEFAULT NULL::character varying,
    path character varying(255) NOT NULL,
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    server_id character varying(50),
    last_server_ping timestamp with time zone,
    error text,
    error_handler_path character varying(255),
    error_handler_args jsonb,
    retry jsonb,
    mode public.trigger_mode DEFAULT 'enabled'::public.trigger_mode NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    labels text[]
);


--
-- Name: native_retry_attempt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.native_retry_attempt (
    job_id uuid NOT NULL,
    attempt integer NOT NULL
);


--
-- Name: native_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.native_trigger (
    external_id character varying(255) NOT NULL,
    workspace_id character varying(50) NOT NULL,
    service_name public.native_trigger_service NOT NULL,
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    service_config jsonb,
    error text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    webhook_token_hash character varying(64) NOT NULL,
    summary character varying(1000)
);


--
-- Name: nats_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nats_trigger (
    path character varying(255) NOT NULL,
    nats_resource_path character varying(255) NOT NULL,
    subjects character varying(255)[] NOT NULL,
    stream_name character varying(255),
    consumer_name character varying(255),
    use_jetstream boolean NOT NULL,
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    server_id character varying(50),
    last_server_ping timestamp with time zone,
    error text,
    error_handler_path character varying(255),
    error_handler_args jsonb,
    retry jsonb,
    mode public.trigger_mode DEFAULT 'enabled'::public.trigger_mode NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    labels text[]
);


--
-- Name: notify_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notify_event (
    id bigint NOT NULL,
    channel text NOT NULL,
    payload text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: notify_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notify_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notify_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notify_event_id_seq OWNED BY public.notify_event.id;


--
-- Name: otel_traces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.otel_traces (
    trace_id bytea NOT NULL,
    span_id bytea NOT NULL,
    trace_state text DEFAULT ''::text NOT NULL,
    parent_span_id bytea DEFAULT '\x'::bytea NOT NULL,
    flags integer DEFAULT 0 NOT NULL,
    name text NOT NULL,
    kind integer NOT NULL,
    start_time_unix_nano bigint NOT NULL,
    end_time_unix_nano bigint NOT NULL,
    attributes jsonb DEFAULT '[]'::jsonb NOT NULL,
    dropped_attributes_count integer DEFAULT 0 NOT NULL,
    events jsonb DEFAULT '[]'::jsonb NOT NULL,
    dropped_events_count integer DEFAULT 0 NOT NULL,
    links jsonb DEFAULT '[]'::jsonb NOT NULL,
    dropped_links_count integer DEFAULT 0 NOT NULL,
    status jsonb
);


--
-- Name: outstanding_wait_time; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outstanding_wait_time (
    job_id uuid NOT NULL,
    self_wait_time_ms bigint,
    aggregate_wait_time_ms bigint
);


--
-- Name: parallel_monitor_lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parallel_monitor_lock (
    parent_flow_id uuid NOT NULL,
    job_id uuid NOT NULL,
    last_ping timestamp with time zone
);


--
-- Name: password; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password (
    email character varying(255) NOT NULL,
    password_hash character varying(100),
    login_type character varying(50) NOT NULL,
    super_admin boolean DEFAULT false NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    name character varying(255),
    company character varying(255),
    first_time_user boolean DEFAULT false NOT NULL,
    username character varying(50),
    devops boolean DEFAULT false NOT NULL,
    role_source character varying(20) DEFAULT 'manual'::character varying NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    CONSTRAINT check_role_source CHECK (((role_source)::text = ANY ((ARRAY['manual'::character varying, 'instance_group'::character varying])::text[])))
);


--
-- Name: pending_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pending_user (
    email character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    username character varying(50) NOT NULL
);


--
-- Name: pip_resolution_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pip_resolution_cache (
    hash character varying(255) NOT NULL,
    expiration timestamp without time zone NOT NULL,
    lockfile text NOT NULL
);


--
-- Name: pipeline_freshness_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pipeline_freshness_state (
    workspace_id character varying(50) NOT NULL,
    script_path character varying(510) NOT NULL,
    attempts integer DEFAULT 1 NOT NULL,
    last_push_at timestamp with time zone DEFAULT now() NOT NULL,
    next_attempt_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: postgres_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postgres_trigger (
    path character varying(255) NOT NULL,
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    extra_perms jsonb,
    postgres_resource_path character varying(255) NOT NULL,
    error text,
    server_id character varying(50),
    last_server_ping timestamp with time zone,
    replication_slot_name character varying(255) NOT NULL,
    publication_name character varying(255) NOT NULL,
    error_handler_path character varying(255),
    error_handler_args jsonb,
    retry jsonb,
    mode public.trigger_mode DEFAULT 'enabled'::public.trigger_mode NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    labels text[]
);


--
-- Name: raw_app; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.raw_app (
    path character varying(255) NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    workspace_id character varying(50) NOT NULL,
    summary character varying(1000) DEFAULT ''::character varying NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    data text NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    labels text[]
);


--
-- Name: raw_script_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.raw_script_temp (
    workspace_id character varying(50) NOT NULL,
    hash character(64) NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: resource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource (
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    value jsonb,
    description text,
    resource_type character varying(50) NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    edited_at timestamp with time zone,
    created_by character varying(500),
    labels text[],
    CONSTRAINT proper_id CHECK (((path)::text ~ '^[ufg](\/[\w-]+){2,}$'::text))
);


--
-- Name: resource_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_type (
    workspace_id character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    schema jsonb,
    description text,
    edited_at timestamp with time zone,
    created_by character varying(50),
    format_extension character varying(20),
    is_fileset boolean DEFAULT false NOT NULL,
    CONSTRAINT proper_name CHECK (((name)::text ~ '^[\w-]+$'::text))
);


--
-- Name: resource_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_version (
    id bigint NOT NULL,
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    resource_type character varying(50) NOT NULL,
    value jsonb,
    created_by character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: resource_version_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.resource_version ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.resource_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: resume_job; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resume_job (
    id uuid NOT NULL,
    job uuid NOT NULL,
    flow uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    value jsonb DEFAULT 'null'::jsonb NOT NULL,
    approver character varying(1000),
    resume_id integer DEFAULT 0 NOT NULL,
    approved boolean DEFAULT true NOT NULL
);


--
-- Name: retry_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.retry_settings (
    hash bigint NOT NULL,
    constant_attempts integer,
    constant_seconds integer,
    exponential_attempts integer,
    exponential_multiplier integer,
    exponential_seconds integer,
    exponential_random_factor integer,
    retry_if_expr text
);


--
-- Name: runnable_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.runnable_settings (
    hash bigint NOT NULL,
    debouncing_settings bigint,
    concurrency_settings bigint,
    retry_settings bigint
);


--
-- Name: schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedule (
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    edited_by character varying(255) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    schedule character varying(255) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    script_path character varying(255) NOT NULL,
    args jsonb,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_flow boolean DEFAULT false NOT NULL,
    email character varying(255) DEFAULT 'missing@email.xyz'::character varying NOT NULL,
    error text,
    timezone character varying(255) DEFAULT 'UTC'::character varying NOT NULL,
    on_failure character varying(1000) DEFAULT NULL::character varying,
    on_recovery character varying(1000),
    on_failure_times integer,
    on_failure_exact boolean,
    on_failure_extra_args jsonb,
    on_recovery_times integer,
    on_recovery_extra_args jsonb,
    ws_error_handler_muted boolean DEFAULT false NOT NULL,
    retry jsonb,
    summary character varying(512),
    no_flow_overlap boolean DEFAULT false NOT NULL,
    tag character varying(50),
    paused_until timestamp with time zone,
    on_success character varying(1000),
    on_success_extra_args jsonb,
    cron_version text DEFAULT 'v1'::text,
    description text,
    dynamic_skip character varying(1000) DEFAULT NULL::character varying,
    permissioned_as character varying(255) NOT NULL,
    labels text[],
    CONSTRAINT proper_id CHECK (((path)::text ~ '^[ufg](\/[\w-]+){2,}$'::text))
);


--
-- Name: script; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.script (
    workspace_id character varying(50) NOT NULL,
    hash bigint NOT NULL,
    path character varying(255) NOT NULL,
    parent_hashes bigint[],
    summary text NOT NULL,
    description text NOT NULL,
    content text NOT NULL,
    created_by character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    schema json,
    deleted boolean DEFAULT false NOT NULL,
    is_template boolean DEFAULT false,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    lock text,
    lock_error_logs text,
    language public.script_lang DEFAULT 'python3'::public.script_lang NOT NULL,
    kind public.script_kind DEFAULT 'script'::public.script_kind NOT NULL,
    tag character varying(50),
    envs character varying(1000)[],
    concurrent_limit integer,
    concurrency_time_window_s integer,
    cache_ttl integer,
    dedicated_worker boolean,
    ws_error_handler_muted boolean DEFAULT false NOT NULL,
    priority smallint,
    timeout integer,
    delete_after_use boolean,
    restart_unless_cancelled boolean,
    concurrency_key character varying(255),
    visible_to_runner_only boolean,
    codebase character varying(255),
    has_preprocessor boolean,
    on_behalf_of_email text,
    schema_validation boolean DEFAULT false NOT NULL,
    assets jsonb,
    debounce_key character varying(255),
    debounce_delay_s integer,
    runnable_settings_handle bigint,
    cache_ignore_s3_path boolean,
    modules jsonb,
    auto_kind character varying(20),
    labels text[],
    delete_after_secs integer,
    on_behalf_of character varying(255),
    CONSTRAINT proper_id CHECK (((path)::text ~ '^[ufg](\/[\w-]+){2,}$'::text))
);


--
-- Name: script_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.script_trigger (
    id bigint NOT NULL,
    workspace_id character varying(50) NOT NULL,
    runnable_kind public.asset_usage_kind NOT NULL,
    runnable_path character varying(255) NOT NULL,
    trigger_kind public.script_trigger_kind NOT NULL,
    trigger_ref text NOT NULL,
    join_all boolean DEFAULT false NOT NULL,
    debounce_s integer,
    retry_count smallint,
    retry_delay_s integer
);


--
-- Name: script_trigger_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.script_trigger_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: script_trigger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.script_trigger_id_seq OWNED BY public.script_trigger.id;


--
-- Name: skip_workspace_diff_tally; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.skip_workspace_diff_tally (
    workspace_id character varying(50) NOT NULL,
    added_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: sqs_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sqs_trigger (
    path character varying(255) NOT NULL,
    queue_url character varying(255) NOT NULL,
    aws_resource_path character varying(255) NOT NULL,
    message_attributes text[],
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    extra_perms jsonb,
    error text,
    server_id character varying(50),
    last_server_ping timestamp with time zone,
    aws_auth_resource_type public.aws_auth_resource_type DEFAULT 'credentials'::public.aws_auth_resource_type NOT NULL,
    error_handler_path character varying(255),
    error_handler_args jsonb,
    retry jsonb,
    mode public.trigger_mode DEFAULT 'enabled'::public.trigger_mode NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    labels text[]
);


--
-- Name: token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token (
    token character varying(50),
    label character varying(1000),
    expiration timestamp with time zone,
    workspace_id character varying(50),
    owner character varying(55),
    email character varying(255),
    super_admin boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone DEFAULT now() NOT NULL,
    scopes text[],
    job uuid,
    token_hash character varying(64) NOT NULL,
    token_prefix character varying(10) NOT NULL,
    read_only boolean DEFAULT false NOT NULL
);


--
-- Name: token_expiry_notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token_expiry_notification (
    token_hash character varying(255) NOT NULL,
    expiration timestamp with time zone NOT NULL
);


--
-- Name: trashbin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trashbin (
    id bigint NOT NULL,
    workspace_id character varying(50) NOT NULL,
    item_kind character varying(50) NOT NULL,
    item_path text NOT NULL,
    item_data jsonb NOT NULL,
    deleted_by character varying(255) NOT NULL,
    deleted_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '3 days'::interval) NOT NULL
);


--
-- Name: trashbin_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.trashbin ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.trashbin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: trigger_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trigger_history (
    id bigint NOT NULL,
    workspace_id character varying(50) NOT NULL,
    trigger_kind character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    operation character varying(20) NOT NULL,
    source character varying(20) NOT NULL,
    username character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    changes jsonb
);


--
-- Name: trigger_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trigger_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trigger_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trigger_history_id_seq OWNED BY public.trigger_history.id;


--
-- Name: tutorial_progress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tutorial_progress (
    email character varying(255) NOT NULL,
    progress bit(64) DEFAULT '0'::"bit" NOT NULL,
    skipped_all boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN tutorial_progress.skipped_all; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tutorial_progress.skipped_all IS 'Indicates if the user has skipped all tutorials (vs completing them all)';


--
-- Name: unique_ext_jwt_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unique_ext_jwt_token (
    jwt_hash bigint NOT NULL,
    last_used_at timestamp with time zone DEFAULT now() NOT NULL,
    email text DEFAULT ''::text NOT NULL,
    username text DEFAULT ''::text NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    is_operator boolean DEFAULT false NOT NULL,
    workspace_id text,
    label text,
    scopes text[]
);


--
-- Name: usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usage (
    id character varying(50) NOT NULL,
    is_workspace boolean NOT NULL,
    month_ integer NOT NULL,
    usage integer NOT NULL
);


--
-- Name: usr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usr (
    workspace_id character varying(50) NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    operator boolean DEFAULT false NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    role character varying(50),
    added_via jsonb,
    is_service_account boolean DEFAULT false NOT NULL,
    CONSTRAINT proper_email CHECK (((email)::text ~* '^(?:[a-z0-9!#$%&''*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$'::text)),
    CONSTRAINT proper_username CHECK (((username)::text ~ '^[\w-]+$'::text))
);


--
-- Name: usr_to_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usr_to_group (
    workspace_id character varying(50) NOT NULL,
    group_ character varying(50) NOT NULL,
    usr character varying(50) DEFAULT 'ruben'::character varying NOT NULL
);


--
-- Name: v2_job; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.v2_job (
    id uuid NOT NULL,
    raw_code text,
    raw_lock text,
    raw_flow jsonb,
    tag character varying(50) DEFAULT 'other'::character varying NOT NULL,
    workspace_id character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(255) DEFAULT 'missing'::character varying NOT NULL,
    permissioned_as character varying(55) DEFAULT 'g/all'::character varying NOT NULL,
    permissioned_as_email character varying(255) DEFAULT 'missing@email.xyz'::character varying NOT NULL,
    kind public.job_kind DEFAULT 'script'::public.job_kind NOT NULL,
    runnable_id bigint,
    runnable_path character varying(255),
    parent_job uuid,
    root_job uuid,
    script_lang public.script_lang DEFAULT 'python3'::public.script_lang,
    script_entrypoint_override character varying(255),
    flow_step integer,
    flow_step_id character varying(255),
    flow_innermost_root_job uuid,
    trigger character varying(255),
    trigger_kind public.job_trigger_kind,
    same_worker boolean DEFAULT false NOT NULL,
    visible_to_owner boolean DEFAULT true NOT NULL,
    concurrent_limit integer,
    concurrency_time_window_s integer,
    cache_ttl integer,
    timeout integer,
    priority smallint,
    preprocessed boolean,
    args jsonb,
    labels text[],
    pre_run_error text
);


--
-- Name: v2_job_completed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.v2_job_completed (
    id uuid NOT NULL,
    workspace_id character varying(50) NOT NULL,
    duration_ms bigint NOT NULL,
    result jsonb,
    deleted boolean DEFAULT false NOT NULL,
    canceled_by character varying(50),
    canceled_reason text,
    flow_status jsonb,
    started_at timestamp with time zone DEFAULT now(),
    memory_peak integer,
    status public.job_status NOT NULL,
    completed_at timestamp with time zone DEFAULT now() NOT NULL,
    worker character varying(255),
    workflow_as_code_status jsonb,
    result_columns text[],
    retries uuid[],
    extras jsonb
);


--
-- Name: v2_as_completed_job; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v2_as_completed_job AS
 SELECT j.id,
    j.workspace_id,
    j.parent_job,
    j.created_by,
    j.created_at,
    c.duration_ms,
    ((c.status = 'success'::public.job_status) OR (c.status = 'skipped'::public.job_status)) AS success,
    j.runnable_id AS script_hash,
    j.runnable_path AS script_path,
    j.args,
    c.result,
    false AS deleted,
    j.raw_code,
    (c.status = 'canceled'::public.job_status) AS canceled,
    c.canceled_by,
    c.canceled_reason,
    j.kind AS job_kind,
        CASE
            WHEN (j.trigger_kind = 'schedule'::public.job_trigger_kind) THEN j.trigger
            ELSE NULL::character varying
        END AS schedule_path,
    j.permissioned_as,
    COALESCE(c.flow_status, c.workflow_as_code_status) AS flow_status,
    j.raw_flow,
    (j.flow_step_id IS NOT NULL) AS is_flow_step,
    j.script_lang AS language,
    c.started_at,
    (c.status = 'skipped'::public.job_status) AS is_skipped,
    j.raw_lock,
    j.permissioned_as_email AS email,
    j.visible_to_owner,
    c.memory_peak AS mem_peak,
    j.tag,
    j.priority,
    NULL::text AS logs,
    c.result_columns,
    j.script_entrypoint_override,
    j.preprocessed
   FROM (public.v2_job_completed c
     JOIN public.v2_job j USING (id));


--
-- Name: v2_job_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.v2_job_queue (
    id uuid NOT NULL,
    workspace_id character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    started_at timestamp with time zone,
    scheduled_for timestamp with time zone NOT NULL,
    running boolean DEFAULT false NOT NULL,
    canceled_by character varying(255),
    canceled_reason text,
    suspend integer DEFAULT 0 NOT NULL,
    suspend_until timestamp with time zone,
    tag character varying(255) DEFAULT 'other'::character varying NOT NULL,
    priority smallint,
    worker character varying(255),
    extras jsonb,
    runnable_settings_handle bigint,
    cache_ignore_s3_path boolean
);


--
-- Name: v2_job_runtime; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.v2_job_runtime (
    id uuid NOT NULL,
    ping timestamp with time zone DEFAULT now(),
    memory_peak integer
);


--
-- Name: v2_job_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.v2_job_status (
    id uuid NOT NULL,
    flow_status jsonb,
    flow_leaf_jobs jsonb,
    workflow_as_code_status jsonb
);


--
-- Name: v2_as_queue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v2_as_queue AS
 SELECT j.id,
    j.workspace_id,
    j.parent_job,
    j.created_by,
    j.created_at,
    q.started_at,
    q.scheduled_for,
    q.running,
    j.runnable_id AS script_hash,
    j.runnable_path AS script_path,
    j.args,
    j.raw_code,
    (q.canceled_by IS NOT NULL) AS canceled,
    q.canceled_by,
    q.canceled_reason,
    r.ping AS last_ping,
    j.kind AS job_kind,
        CASE
            WHEN (j.trigger_kind = 'schedule'::public.job_trigger_kind) THEN j.trigger
            ELSE NULL::character varying
        END AS schedule_path,
    j.permissioned_as,
    COALESCE(s.flow_status, s.workflow_as_code_status) AS flow_status,
    j.raw_flow,
    (j.flow_step_id IS NOT NULL) AS is_flow_step,
    j.script_lang AS language,
    q.suspend,
    q.suspend_until,
    j.same_worker,
    j.raw_lock,
    j.pre_run_error,
    j.permissioned_as_email AS email,
    j.visible_to_owner,
    r.memory_peak AS mem_peak,
    j.flow_innermost_root_job AS root_job,
    s.flow_leaf_jobs AS leaf_jobs,
    j.tag,
    j.concurrent_limit,
    j.concurrency_time_window_s,
    j.timeout,
    j.flow_step_id,
    j.cache_ttl,
    j.priority,
    NULL::text AS logs,
    j.script_entrypoint_override,
    j.preprocessed
   FROM (((public.v2_job_queue q
     JOIN public.v2_job j USING (id))
     LEFT JOIN public.v2_job_runtime r USING (id))
     LEFT JOIN public.v2_job_status s USING (id));


--
-- Name: v2_job_debounce_batch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.v2_job_debounce_batch (
    id uuid NOT NULL,
    debounce_batch bigint DEFAULT nextval('public.debounce_batch_seq'::regclass) NOT NULL,
    consumed_at timestamp with time zone,
    consumed_by uuid
);


--
-- Name: variable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.variable (
    workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    value character varying(15000) NOT NULL,
    is_secret boolean DEFAULT false NOT NULL,
    description character varying(10000) DEFAULT ''::character varying NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    account integer,
    is_oauth boolean DEFAULT false NOT NULL,
    expires_at timestamp with time zone,
    labels text[],
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    edited_by character varying(50),
    CONSTRAINT proper_id CHECK (((path)::text ~ '^[ufg](\/[\w-]+){2,}$'::text))
);


--
-- Name: volume; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.volume (
    workspace_id character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    size_bytes bigint DEFAULT 0 NOT NULL,
    file_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(255) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(255),
    description text DEFAULT ''::text NOT NULL,
    lease_until timestamp with time zone,
    leased_by character varying(255),
    last_used_at timestamp with time zone,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: websocket_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.websocket_trigger (
    path character varying(255) NOT NULL,
    url character varying(1000) NOT NULL,
    script_path character varying(255) NOT NULL,
    is_flow boolean NOT NULL,
    workspace_id character varying(50) NOT NULL,
    edited_by character varying(50) NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    extra_perms jsonb DEFAULT '{}'::jsonb NOT NULL,
    server_id character varying(50),
    last_server_ping timestamp with time zone,
    error text,
    filters jsonb[] DEFAULT '{}'::jsonb[] NOT NULL,
    initial_messages jsonb[] DEFAULT '{}'::jsonb[],
    url_runnable_args jsonb DEFAULT '{}'::jsonb,
    can_return_message boolean DEFAULT false NOT NULL,
    error_handler_path character varying(255),
    error_handler_args jsonb,
    retry jsonb,
    can_return_error_result boolean DEFAULT false NOT NULL,
    mode public.trigger_mode DEFAULT 'enabled'::public.trigger_mode NOT NULL,
    permissioned_as character varying(255) NOT NULL,
    filter_logic character varying(3) DEFAULT 'and'::character varying NOT NULL,
    labels text[],
    heartbeat jsonb
);


--
-- Name: windmill_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.windmill_migrations (
    name text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: worker_group_job_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker_group_job_stats (
    hour bigint NOT NULL,
    worker_group text NOT NULL,
    script_lang character varying(50) NOT NULL,
    workspace_id character varying(50) NOT NULL,
    job_count integer DEFAULT 0 NOT NULL,
    total_duration_ms bigint DEFAULT 0 NOT NULL
);


--
-- Name: worker_ping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker_ping (
    worker character varying(255) NOT NULL,
    worker_instance character varying(255) NOT NULL,
    ping_at timestamp with time zone DEFAULT now() NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ip character varying(50) DEFAULT 'NO IP'::character varying NOT NULL,
    jobs_executed integer DEFAULT 0 NOT NULL,
    custom_tags text[],
    worker_group character varying(255) DEFAULT 'default'::character varying NOT NULL,
    dedicated_worker character varying(255),
    wm_version character varying(255) DEFAULT ''::character varying NOT NULL,
    current_job_id uuid,
    current_job_workspace_id character varying(50),
    vcpus bigint,
    memory bigint,
    occupancy_rate real,
    memory_usage bigint,
    wm_memory_usage bigint,
    occupancy_rate_15s real,
    occupancy_rate_5m real,
    occupancy_rate_30m real,
    job_isolation text,
    dedicated_workers text[],
    native_mode boolean DEFAULT false NOT NULL
);


--
-- Name: workspace; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace (
    id character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    owner character varying(50) NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    premium boolean DEFAULT false NOT NULL,
    parent_workspace_id character varying(50),
    is_dev_workspace boolean DEFAULT false NOT NULL,
    dev_workspace_label character varying,
    CONSTRAINT proper_id CHECK (((id)::text ~ '^\w+(-\w+)*$'::text)),
    CONSTRAINT workspace_dev_requires_parent CHECK (((NOT is_dev_workspace) OR (parent_workspace_id IS NOT NULL)))
);


--
-- Name: workspace_dependencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workspace_dependencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workspace_dependencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_dependencies (
    id bigint DEFAULT nextval('public.workspace_dependencies_id_seq'::regclass) NOT NULL,
    name character varying(255),
    content text NOT NULL,
    language public.script_lang NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    workspace_id character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspace_diff; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_diff (
    source_workspace_id character varying(50) NOT NULL,
    fork_workspace_id character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    kind character varying(50) NOT NULL,
    ahead integer DEFAULT 0 NOT NULL,
    behind integer DEFAULT 0 NOT NULL,
    has_changes boolean,
    exists_in_source boolean,
    exists_in_fork boolean,
    fork_last_event_kind character varying(20),
    fork_last_event_origin character varying(20),
    source_last_event_kind character varying(20),
    source_last_event_origin character varying(20)
);


--
-- Name: workspace_diff_full_scan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_diff_full_scan (
    source_workspace_id character varying(50) NOT NULL,
    fork_workspace_id character varying(50) NOT NULL,
    scanned_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspace_env; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_env (
    workspace_id character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(1000) NOT NULL
);


--
-- Name: workspace_fork_deployment_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_fork_deployment_request (
    id bigint NOT NULL,
    source_workspace_id character varying(50) NOT NULL,
    fork_workspace_id character varying(50) NOT NULL,
    requested_by character varying(255) NOT NULL,
    requested_by_email character varying(255) NOT NULL,
    requested_at timestamp with time zone DEFAULT now() NOT NULL,
    closed_at timestamp with time zone,
    closed_reason character varying(20)
);


--
-- Name: workspace_fork_deployment_request_assignee; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_fork_deployment_request_assignee (
    request_id bigint NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL
);


--
-- Name: workspace_fork_deployment_request_comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_fork_deployment_request_comment (
    id bigint NOT NULL,
    request_id bigint NOT NULL,
    parent_id bigint,
    author character varying(255) NOT NULL,
    author_email character varying(255) NOT NULL,
    body text NOT NULL,
    anchor_kind character varying(50),
    anchor_path character varying(255),
    obsolete boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT anchor_kind_path_both_or_neither CHECK (((anchor_kind IS NULL) = (anchor_path IS NULL)))
);


--
-- Name: workspace_fork_deployment_request_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workspace_fork_deployment_request_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workspace_fork_deployment_request_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workspace_fork_deployment_request_comment_id_seq OWNED BY public.workspace_fork_deployment_request_comment.id;


--
-- Name: workspace_fork_deployment_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workspace_fork_deployment_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workspace_fork_deployment_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workspace_fork_deployment_request_id_seq OWNED BY public.workspace_fork_deployment_request.id;


--
-- Name: workspace_integrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_integrations (
    workspace_id character varying(50) NOT NULL,
    service_name public.native_trigger_service NOT NULL,
    oauth_data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(50) NOT NULL,
    resource_path text
);


--
-- Name: workspace_invite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_invite (
    workspace_id character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    operator boolean DEFAULT false NOT NULL,
    CONSTRAINT proper_email CHECK (((email)::text ~* '^(?:[a-z0-9!#$%&''*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$'::text))
);


--
-- Name: workspace_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_key (
    workspace_id character varying(50) NOT NULL,
    kind public.workspace_key_kind NOT NULL,
    key character varying(255) DEFAULT 'changeme'::character varying NOT NULL
);


--
-- Name: workspace_multipart_inflight; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_multipart_inflight (
    workspace_id character varying(50) NOT NULL,
    upload_id character varying(512) NOT NULL,
    part_id character varying(256) NOT NULL,
    storage character varying(255) NOT NULL,
    part_bytes bigint DEFAULT 0 NOT NULL,
    target_existing_size bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspace_protection_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_protection_rule (
    workspace_id character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    rules integer NOT NULL,
    bypass_groups text[] DEFAULT '{}'::text[] NOT NULL,
    bypass_users text[] DEFAULT '{}'::text[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspace_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_settings (
    workspace_id character varying(50) NOT NULL,
    slack_team_id character varying(50),
    slack_name character varying(50),
    slack_command_script character varying(255),
    slack_email character varying(50) DEFAULT 'missing@email.xyz'::character varying NOT NULL,
    customer_id character varying(100),
    plan character varying(40),
    webhook text,
    ai_config jsonb,
    large_file_storage jsonb,
    git_sync jsonb,
    default_app character varying(255),
    default_scripts jsonb,
    deploy_ui jsonb,
    mute_critical_alerts boolean,
    color character varying(7) DEFAULT NULL::character varying,
    operator_settings jsonb DEFAULT '{"runs": true, "assets": true, "groups": true, "folders": true, "workers": true, "triggers": true, "resources": true, "schedules": true, "variables": true, "audit_logs": true}'::jsonb,
    teams_command_script text,
    teams_team_id text,
    teams_team_name text,
    git_app_installations jsonb DEFAULT '[]'::jsonb NOT NULL,
    ducklake jsonb,
    slack_oauth_client_id character varying(255) DEFAULT NULL::character varying,
    slack_oauth_client_secret character varying(255) DEFAULT NULL::character varying,
    datatable jsonb,
    teams_team_guid text,
    auto_invite jsonb,
    error_handler jsonb,
    success_handler jsonb,
    public_app_execution_limit_per_minute integer,
    error_handler_fallback_to_instance_alerts boolean DEFAULT false NOT NULL,
    dbt_warehouses jsonb
);


--
-- Name: workspace_shared_ui; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_shared_ui (
    workspace_id character varying(50) NOT NULL,
    files jsonb DEFAULT '{}'::jsonb NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    edited_at timestamp with time zone DEFAULT now() NOT NULL,
    edited_by character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: workspace_storage_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_storage_usage (
    workspace_id character varying(50) NOT NULL,
    storage character varying(255) NOT NULL,
    bytes bigint DEFAULT 0 NOT NULL,
    computed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ws_specific; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ws_specific (
    workspace_id character varying(50) NOT NULL,
    item_kind character varying(50) NOT NULL,
    path character varying(255) NOT NULL
);


--
-- Name: zombie_job_counter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zombie_job_counter (
    job_id uuid NOT NULL,
    counter integer DEFAULT 0 NOT NULL
);


--
-- Name: audit_20260815; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_partitioned ATTACH PARTITION public.audit_20260815 FOR VALUES FROM ('2026-08-15 00:00:00+00') TO ('2026-08-16 00:00:00+00');


--
-- Name: audit_20260816; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_partitioned ATTACH PARTITION public.audit_20260816 FOR VALUES FROM ('2026-08-16 00:00:00+00') TO ('2026-08-17 00:00:00+00');


--
-- Name: audit_20260817; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_partitioned ATTACH PARTITION public.audit_20260817 FOR VALUES FROM ('2026-08-17 00:00:00+00') TO ('2026-08-18 00:00:00+00');


--
-- Name: audit_20260818; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_partitioned ATTACH PARTITION public.audit_20260818 FOR VALUES FROM ('2026-08-18 00:00:00+00') TO ('2026-08-19 00:00:00+00');


--
-- Name: account id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account ALTER COLUMN id SET DEFAULT nextval('public.account_id_seq'::regclass);


--
-- Name: alerts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts ALTER COLUMN id SET DEFAULT nextval('public.alerts_id_seq'::regclass);


--
-- Name: app id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app ALTER COLUMN id SET DEFAULT nextval('public.app_id_seq'::regclass);


--
-- Name: app_script id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_script ALTER COLUMN id SET DEFAULT nextval('public.app_script_id_seq'::regclass);


--
-- Name: app_script app; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_script ALTER COLUMN app SET DEFAULT nextval('public.app_script_app_seq'::regclass);


--
-- Name: app_version id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_version ALTER COLUMN id SET DEFAULT nextval('public.app_version_id_seq'::regclass);


--
-- Name: app_version_lite id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_version_lite ALTER COLUMN id SET DEFAULT nextval('public.app_version_lite_id_seq'::regclass);


--
-- Name: asset id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset ALTER COLUMN id SET DEFAULT nextval('public.asset_id_seq'::regclass);


--
-- Name: audit id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit ALTER COLUMN id SET DEFAULT nextval('public.audit_id_seq'::regclass);


--
-- Name: autoscaling_event id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autoscaling_event ALTER COLUMN id SET DEFAULT nextval('public.autoscaling_event_id_seq'::regclass);


--
-- Name: dispatch_event id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispatch_event ALTER COLUMN id SET DEFAULT nextval('public.dispatch_event_id_seq'::regclass);


--
-- Name: draft id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.draft ALTER COLUMN id SET DEFAULT nextval('public.draft_id_seq'::regclass);


--
-- Name: flow_node id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_node ALTER COLUMN id SET DEFAULT nextval('public.flow_node_id_seq'::regclass);


--
-- Name: flow_version id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_version ALTER COLUMN id SET DEFAULT nextval('public.flow_version_id_seq'::regclass);


--
-- Name: flow_version_lite id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_version_lite ALTER COLUMN id SET DEFAULT nextval('public.flow_version_lite_id_seq'::regclass);


--
-- Name: folder_permission_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folder_permission_history ALTER COLUMN id SET DEFAULT nextval('public.folder_permission_history_id_seq'::regclass);


--
-- Name: group_permission_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_permission_history ALTER COLUMN id SET DEFAULT nextval('public.group_permission_history_id_seq'::regclass);


--
-- Name: healthchecks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.healthchecks ALTER COLUMN id SET DEFAULT nextval('public.healthchecks_id_seq'::regclass);


--
-- Name: kafka_pending_commits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kafka_pending_commits ALTER COLUMN id SET DEFAULT nextval('public.kafka_pending_commits_id_seq'::regclass);


--
-- Name: mcp_oauth_refresh_token id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcp_oauth_refresh_token ALTER COLUMN id SET DEFAULT nextval('public.mcp_oauth_refresh_token_id_seq'::regclass);


--
-- Name: notify_event id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notify_event ALTER COLUMN id SET DEFAULT nextval('public.notify_event_id_seq'::regclass);


--
-- Name: script_trigger id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.script_trigger ALTER COLUMN id SET DEFAULT nextval('public.script_trigger_id_seq'::regclass);


--
-- Name: trigger_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trigger_history ALTER COLUMN id SET DEFAULT nextval('public.trigger_history_id_seq'::regclass);


--
-- Name: workspace_fork_deployment_request id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_fork_deployment_request ALTER COLUMN id SET DEFAULT nextval('public.workspace_fork_deployment_request_id_seq'::regclass);


--
-- Name: workspace_fork_deployment_request_comment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_fork_deployment_request_comment ALTER COLUMN id SET DEFAULT nextval('public.workspace_fork_deployment_request_comment_id_seq'::regclass);


--
-- Name: _sqlx_migrations _sqlx_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._sqlx_migrations
    ADD CONSTRAINT _sqlx_migrations_pkey PRIMARY KEY (version);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (workspace_id, id);


--
-- Name: agent_token_blacklist agent_token_blacklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_token_blacklist
    ADD CONSTRAINT agent_token_blacklist_pkey PRIMARY KEY (token);


--
-- Name: ai_agent_memory ai_agent_memory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agent_memory
    ADD CONSTRAINT ai_agent_memory_pkey PRIMARY KEY (workspace_id, conversation_id, step_id);


--
-- Name: ai_skill ai_skill_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_skill
    ADD CONSTRAINT ai_skill_pkey PRIMARY KEY (workspace_id, name);


--
-- Name: alerts alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (id);


--
-- Name: amqp_trigger amqp_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amqp_trigger
    ADD CONSTRAINT amqp_trigger_pkey PRIMARY KEY (path, workspace_id);


--
-- Name: app_bundles app_bundles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_bundles
    ADD CONSTRAINT app_bundles_pkey PRIMARY KEY (app_version_id, file_type);


--
-- Name: app app_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app
    ADD CONSTRAINT app_pkey PRIMARY KEY (id);


--
-- Name: app_script app_script_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_script
    ADD CONSTRAINT app_script_hash_key UNIQUE (hash);


--
-- Name: app_script app_script_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_script
    ADD CONSTRAINT app_script_pkey PRIMARY KEY (id);


--
-- Name: app_version_lite app_version_lite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_version_lite
    ADD CONSTRAINT app_version_lite_pkey PRIMARY KEY (id);


--
-- Name: app_version app_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_version
    ADD CONSTRAINT app_version_pkey PRIMARY KEY (id);


--
-- Name: asset asset_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT asset_id_key UNIQUE (id);


--
-- Name: asset asset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT asset_pkey PRIMARY KEY (workspace_id, path, kind, usage_path, usage_kind);


--
-- Name: audit_partitioned audit_partitioned_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_partitioned
    ADD CONSTRAINT audit_partitioned_pkey PRIMARY KEY (id, "timestamp");


--
-- Name: audit_20260815 audit_20260815_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_20260815
    ADD CONSTRAINT audit_20260815_pkey PRIMARY KEY (id, "timestamp");


--
-- Name: audit_20260816 audit_20260816_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_20260816
    ADD CONSTRAINT audit_20260816_pkey PRIMARY KEY (id, "timestamp");


--
-- Name: audit_20260817 audit_20260817_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_20260817
    ADD CONSTRAINT audit_20260817_pkey PRIMARY KEY (id, "timestamp");


--
-- Name: audit_20260818 audit_20260818_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_20260818
    ADD CONSTRAINT audit_20260818_pkey PRIMARY KEY (id, "timestamp");


--
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (workspace_id, id);


--
-- Name: autoscaling_event autoscaling_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autoscaling_event
    ADD CONSTRAINT autoscaling_event_pkey PRIMARY KEY (id);


--
-- Name: azure_trigger azure_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.azure_trigger
    ADD CONSTRAINT azure_trigger_pkey PRIMARY KEY (path, workspace_id);


--
-- Name: background_task_state background_task_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_task_state
    ADD CONSTRAINT background_task_state_pkey PRIMARY KEY (name);


--
-- Name: capture_config capture_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capture_config
    ADD CONSTRAINT capture_config_pkey PRIMARY KEY (workspace_id, path, is_flow, trigger_kind);


--
-- Name: capture capture_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_pkey PRIMARY KEY (id);


--
-- Name: ci_test_reference ci_test_reference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ci_test_reference
    ADD CONSTRAINT ci_test_reference_pkey PRIMARY KEY (workspace_id, test_script_path, tested_item_path, tested_item_kind);


--
-- Name: cloud_workspace_settings cloud_workspace_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloud_workspace_settings
    ADD CONSTRAINT cloud_workspace_settings_pkey PRIMARY KEY (workspace_id);


--
-- Name: v2_job_completed completed_job_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2_job_completed
    ADD CONSTRAINT completed_job_pkey PRIMARY KEY (id);


--
-- Name: concurrency_counter concurrency_counter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concurrency_counter
    ADD CONSTRAINT concurrency_counter_pkey PRIMARY KEY (concurrency_id);


--
-- Name: concurrency_key concurrency_key_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concurrency_key
    ADD CONSTRAINT concurrency_key_pkey PRIMARY KEY (job_id);


--
-- Name: concurrency_locks concurrency_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concurrency_locks
    ADD CONSTRAINT concurrency_locks_pkey PRIMARY KEY (id);


--
-- Name: concurrency_settings concurrency_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concurrency_settings
    ADD CONSTRAINT concurrency_settings_pkey PRIMARY KEY (hash);


--
-- Name: custom_concurrency_key_ended custom_concurrency_key_ended_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_concurrency_key_ended
    ADD CONSTRAINT custom_concurrency_key_ended_pkey PRIMARY KEY (key, ended_at);


--
-- Name: data_metric data_metric_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_metric
    ADD CONSTRAINT data_metric_pkey PRIMARY KEY (workspace_id, script_path, kind, name);


--
-- Name: datatable_migrations datatable_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatable_migrations
    ADD CONSTRAINT datatable_migrations_pkey PRIMARY KEY (workspace_id, datatable, "timestamp");


--
-- Name: dbt_run_progress dbt_run_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dbt_run_progress
    ADD CONSTRAINT dbt_run_progress_pkey PRIMARY KEY (workspace_id, job_id, asset_kind, asset_path);


--
-- Name: dbt_run_state dbt_run_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dbt_run_state
    ADD CONSTRAINT dbt_run_state_pkey PRIMARY KEY (workspace_id, script_path, permissioned_as);


--
-- Name: debounce_key debounce_key_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debounce_key
    ADD CONSTRAINT debounce_key_pkey PRIMARY KEY (key);


--
-- Name: debounce_stale_data debounce_stale_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debounce_stale_data
    ADD CONSTRAINT debounce_stale_data_pkey PRIMARY KEY (job_id);


--
-- Name: debouncing_settings debouncing_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debouncing_settings
    ADD CONSTRAINT debouncing_settings_pkey PRIMARY KEY (hash);


--
-- Name: dependency_map dependency_map_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dependency_map
    ADD CONSTRAINT dependency_map_pkey PRIMARY KEY (workspace_id, importer_node_id, importer_kind, importer_path, imported_path);


--
-- Name: dispatch_event dispatch_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispatch_event
    ADD CONSTRAINT dispatch_event_pkey PRIMARY KEY (id);


--
-- Name: draft draft_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.draft
    ADD CONSTRAINT draft_pkey PRIMARY KEY (id);


--
-- Name: email_to_igroup email_to_igroup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_to_igroup
    ADD CONSTRAINT email_to_igroup_pkey PRIMARY KEY (email, igroup);


--
-- Name: email_trigger email_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_trigger
    ADD CONSTRAINT email_trigger_pkey PRIMARY KEY (path, workspace_id);


--
-- Name: favorite favorite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite
    ADD CONSTRAINT favorite_pkey PRIMARY KEY (usr, workspace_id, favorite_kind, path);


--
-- Name: feature_usage feature_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_usage
    ADD CONSTRAINT feature_usage_pkey PRIMARY KEY (feature, kind, key, entity_id, day);


--
-- Name: flow_conversation_message flow_conversation_message_created_seq_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_conversation_message
    ADD CONSTRAINT flow_conversation_message_created_seq_key UNIQUE (created_seq);


--
-- Name: flow_conversation_message flow_conversation_message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_conversation_message
    ADD CONSTRAINT flow_conversation_message_pkey PRIMARY KEY (id);


--
-- Name: flow_conversation flow_conversation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_conversation
    ADD CONSTRAINT flow_conversation_pkey PRIMARY KEY (id);


--
-- Name: flow_iterator_data flow_iterator_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_iterator_data
    ADD CONSTRAINT flow_iterator_data_pkey PRIMARY KEY (job_id);


--
-- Name: flow_node flow_node_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_node
    ADD CONSTRAINT flow_node_pkey PRIMARY KEY (id);


--
-- Name: flow_node flow_node_unique_2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_node
    ADD CONSTRAINT flow_node_unique_2 UNIQUE (path, workspace_id, hash_v2);


--
-- Name: flow flow_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow
    ADD CONSTRAINT flow_pkey PRIMARY KEY (workspace_id, path);


--
-- Name: flow_version_lite flow_version_lite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_version_lite
    ADD CONSTRAINT flow_version_lite_pkey PRIMARY KEY (id);


--
-- Name: flow_version flow_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_version
    ADD CONSTRAINT flow_version_pkey PRIMARY KEY (id);


--
-- Name: folder_permission_history folder_permission_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folder_permission_history
    ADD CONSTRAINT folder_permission_history_pkey PRIMARY KEY (id);


--
-- Name: folder folder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT folder_pkey PRIMARY KEY (workspace_id, name);


--
-- Name: fork_ducklake_namespace fork_ducklake_namespace_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fork_ducklake_namespace
    ADD CONSTRAINT fork_ducklake_namespace_pkey PRIMARY KEY (workspace_id, ducklake_name, catalog, storage, storage_ref, data_path);


--
-- Name: gcp_trigger gcp_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcp_trigger
    ADD CONSTRAINT gcp_trigger_pkey PRIMARY KEY (path, workspace_id);


--
-- Name: global_settings global_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.global_settings
    ADD CONSTRAINT global_settings_pkey PRIMARY KEY (name);


--
-- Name: group_ group__pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_
    ADD CONSTRAINT group__pkey PRIMARY KEY (workspace_id, name);


--
-- Name: group_permission_history group_permission_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_permission_history
    ADD CONSTRAINT group_permission_history_pkey PRIMARY KEY (id);


--
-- Name: healthchecks healthchecks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.healthchecks
    ADD CONSTRAINT healthchecks_pkey PRIMARY KEY (id);


--
-- Name: http_trigger http_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.http_trigger
    ADD CONSTRAINT http_trigger_pkey PRIMARY KEY (path, workspace_id);


--
-- Name: input input_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.input
    ADD CONSTRAINT input_pkey PRIMARY KEY (id);


--
-- Name: instance_group instance_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance_group
    ADD CONSTRAINT instance_group_pkey PRIMARY KEY (name);


--
-- Name: job_delete_schedule job_delete_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_delete_schedule
    ADD CONSTRAINT job_delete_schedule_pkey PRIMARY KEY (job_id);


--
-- Name: job_logs job_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_logs
    ADD CONSTRAINT job_logs_pkey PRIMARY KEY (job_id);


--
-- Name: job_perms job_perms_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_perms
    ADD CONSTRAINT job_perms_pk PRIMARY KEY (job_id);


--
-- Name: v2_job job_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2_job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: job_resolution job_resolution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_resolution
    ADD CONSTRAINT job_resolution_pkey PRIMARY KEY (job_id);


--
-- Name: job_result_stream job_result_stream_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_result_stream
    ADD CONSTRAINT job_result_stream_pkey PRIMARY KEY (job_id);


--
-- Name: job_result_stream_v2 job_result_stream_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_result_stream_v2
    ADD CONSTRAINT job_result_stream_v2_pkey PRIMARY KEY (job_id, idx);


--
-- Name: job_settings job_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_settings
    ADD CONSTRAINT job_settings_pkey PRIMARY KEY (job_id);


--
-- Name: job_stats job_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_stats
    ADD CONSTRAINT job_stats_pkey PRIMARY KEY (workspace_id, job_id, metric_id);


--
-- Name: join_pending_inputs join_pending_inputs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.join_pending_inputs
    ADD CONSTRAINT join_pending_inputs_pkey PRIMARY KEY (workspace_id, subscriber_path, partition, trigger_ref);


--
-- Name: kafka_pending_commits kafka_pending_commits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kafka_pending_commits
    ADD CONSTRAINT kafka_pending_commits_pkey PRIMARY KEY (id);


--
-- Name: kafka_trigger kafka_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kafka_trigger
    ADD CONSTRAINT kafka_trigger_pkey PRIMARY KEY (path, workspace_id);


--
-- Name: lock_hash lock_hash_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lock_hash
    ADD CONSTRAINT lock_hash_pkey PRIMARY KEY (workspace_id, path);


--
-- Name: log_file log_file_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_file
    ADD CONSTRAINT log_file_pkey PRIMARY KEY (hostname, log_ts);


--
-- Name: macro_definition macro_definition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.macro_definition
    ADD CONSTRAINT macro_definition_pkey PRIMARY KEY (workspace_id, name);


--
-- Name: macro_usage macro_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.macro_usage
    ADD CONSTRAINT macro_usage_pkey PRIMARY KEY (workspace_id, consumer_path, macro_name);


--
-- Name: magic_link magic_link_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.magic_link
    ADD CONSTRAINT magic_link_pkey PRIMARY KEY (email, token);


--
-- Name: materialized_asset_schema materialized_asset_schema_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materialized_asset_schema
    ADD CONSTRAINT materialized_asset_schema_pkey PRIMARY KEY (workspace_id, asset_kind, asset_path, version);


--
-- Name: materialized_partition materialized_partition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materialized_partition
    ADD CONSTRAINT materialized_partition_pkey PRIMARY KEY (workspace_id, asset_kind, asset_path, partition);


--
-- Name: mcp_oauth_client mcp_oauth_client_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcp_oauth_client
    ADD CONSTRAINT mcp_oauth_client_pkey PRIMARY KEY (mcp_server_url);


--
-- Name: mcp_oauth_refresh_token mcp_oauth_refresh_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcp_oauth_refresh_token
    ADD CONSTRAINT mcp_oauth_refresh_token_pkey PRIMARY KEY (id);


--
-- Name: mcp_oauth_refresh_token mcp_oauth_refresh_token_refresh_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcp_oauth_refresh_token
    ADD CONSTRAINT mcp_oauth_refresh_token_refresh_token_key UNIQUE (refresh_token);


--
-- Name: mcp_oauth_server_client mcp_oauth_server_client_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcp_oauth_server_client
    ADD CONSTRAINT mcp_oauth_server_client_pkey PRIMARY KEY (client_id);


--
-- Name: mcp_oauth_server_code mcp_oauth_server_code_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcp_oauth_server_code
    ADD CONSTRAINT mcp_oauth_server_code_pkey PRIMARY KEY (code);


--
-- Name: mqtt_trigger mqtt_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mqtt_trigger
    ADD CONSTRAINT mqtt_trigger_pkey PRIMARY KEY (path, workspace_id);


--
-- Name: native_retry_attempt native_retry_attempt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.native_retry_attempt
    ADD CONSTRAINT native_retry_attempt_pkey PRIMARY KEY (job_id);


--
-- Name: native_trigger native_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.native_trigger
    ADD CONSTRAINT native_trigger_pkey PRIMARY KEY (external_id, workspace_id, service_name);


--
-- Name: nats_trigger nats_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nats_trigger
    ADD CONSTRAINT nats_trigger_pkey PRIMARY KEY (path, workspace_id);


--
-- Name: notify_event notify_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notify_event
    ADD CONSTRAINT notify_event_pkey PRIMARY KEY (id);


--
-- Name: otel_traces otel_traces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.otel_traces
    ADD CONSTRAINT otel_traces_pkey PRIMARY KEY (trace_id, span_id);


--
-- Name: outstanding_wait_time outstanding_wait_time_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outstanding_wait_time
    ADD CONSTRAINT outstanding_wait_time_pkey PRIMARY KEY (job_id);


--
-- Name: parallel_monitor_lock parallel_monitor_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parallel_monitor_lock
    ADD CONSTRAINT parallel_monitor_lock_pkey PRIMARY KEY (parent_flow_id, job_id);


--
-- Name: password password_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password
    ADD CONSTRAINT password_pkey PRIMARY KEY (email);


--
-- Name: pending_user pending_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_user
    ADD CONSTRAINT pending_user_pkey PRIMARY KEY (email);


--
-- Name: pip_resolution_cache pip_resolution_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pip_resolution_cache
    ADD CONSTRAINT pip_resolution_cache_pkey PRIMARY KEY (hash);


--
-- Name: pipeline_freshness_state pipeline_freshness_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pipeline_freshness_state
    ADD CONSTRAINT pipeline_freshness_state_pkey PRIMARY KEY (workspace_id, script_path);


--
-- Name: postgres_trigger pk_postgres_trigger; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postgres_trigger
    ADD CONSTRAINT pk_postgres_trigger PRIMARY KEY (path, workspace_id);


--
-- Name: sqs_trigger pk_sqs_trigger; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sqs_trigger
    ADD CONSTRAINT pk_sqs_trigger PRIMARY KEY (path, workspace_id);


--
-- Name: v2_job_queue queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2_job_queue
    ADD CONSTRAINT queue_pkey PRIMARY KEY (id);


--
-- Name: raw_app raw_app_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raw_app
    ADD CONSTRAINT raw_app_pkey PRIMARY KEY (path);


--
-- Name: raw_script_temp raw_script_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raw_script_temp
    ADD CONSTRAINT raw_script_temp_pkey PRIMARY KEY (workspace_id, hash);


--
-- Name: resource resource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_pkey PRIMARY KEY (workspace_id, path);


--
-- Name: resource_type resource_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_type
    ADD CONSTRAINT resource_type_pkey PRIMARY KEY (workspace_id, name);


--
-- Name: resource_version resource_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_version
    ADD CONSTRAINT resource_version_pkey PRIMARY KEY (id);


--
-- Name: resume_job resume_job_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resume_job
    ADD CONSTRAINT resume_job_pkey PRIMARY KEY (id);


--
-- Name: retry_settings retry_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retry_settings
    ADD CONSTRAINT retry_settings_pkey PRIMARY KEY (hash);


--
-- Name: runnable_settings runnable_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runnable_settings
    ADD CONSTRAINT runnable_settings_pkey PRIMARY KEY (hash);


--
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (workspace_id, path);


--
-- Name: script script_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.script
    ADD CONSTRAINT script_pkey PRIMARY KEY (workspace_id, hash);


--
-- Name: script_trigger script_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.script_trigger
    ADD CONSTRAINT script_trigger_pkey PRIMARY KEY (id);


--
-- Name: skip_workspace_diff_tally skip_workspace_diff_tally_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.skip_workspace_diff_tally
    ADD CONSTRAINT skip_workspace_diff_tally_pkey PRIMARY KEY (workspace_id);


--
-- Name: token_expiry_notification token_expiry_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_expiry_notification
    ADD CONSTRAINT token_expiry_notification_pkey PRIMARY KEY (token_hash);


--
-- Name: token token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_pkey PRIMARY KEY (token_hash);


--
-- Name: trashbin trashbin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trashbin
    ADD CONSTRAINT trashbin_pkey PRIMARY KEY (id);


--
-- Name: trigger_history trigger_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trigger_history
    ADD CONSTRAINT trigger_history_pkey PRIMARY KEY (id);


--
-- Name: tutorial_progress tutorial_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutorial_progress
    ADD CONSTRAINT tutorial_progress_pkey PRIMARY KEY (email);


--
-- Name: unique_ext_jwt_token unique_ext_jwt_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unique_ext_jwt_token
    ADD CONSTRAINT unique_ext_jwt_token_pkey PRIMARY KEY (jwt_hash);


--
-- Name: app unique_path_workspace_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app
    ADD CONSTRAINT unique_path_workspace_id UNIQUE (workspace_id, path);


--
-- Name: usage usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usage
    ADD CONSTRAINT usage_pkey PRIMARY KEY (id, is_workspace, month_);


--
-- Name: usr usr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usr
    ADD CONSTRAINT usr_pkey PRIMARY KEY (workspace_id, username);


--
-- Name: usr_to_group usr_to_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usr_to_group
    ADD CONSTRAINT usr_to_group_pkey PRIMARY KEY (workspace_id, usr, group_);


--
-- Name: v2_job_debounce_batch v2_job_debounce_batch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2_job_debounce_batch
    ADD CONSTRAINT v2_job_debounce_batch_pkey PRIMARY KEY (id);


--
-- Name: v2_job_runtime v2_job_runtime_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2_job_runtime
    ADD CONSTRAINT v2_job_runtime_pkey PRIMARY KEY (id);


--
-- Name: v2_job_status v2_job_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2_job_status
    ADD CONSTRAINT v2_job_status_pkey PRIMARY KEY (id);


--
-- Name: variable variable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variable
    ADD CONSTRAINT variable_pkey PRIMARY KEY (workspace_id, path);


--
-- Name: volume volume_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volume
    ADD CONSTRAINT volume_pkey PRIMARY KEY (workspace_id, name);


--
-- Name: websocket_trigger websocket_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.websocket_trigger
    ADD CONSTRAINT websocket_trigger_pkey PRIMARY KEY (path, workspace_id);


--
-- Name: windmill_migrations windmill_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.windmill_migrations
    ADD CONSTRAINT windmill_migrations_pkey PRIMARY KEY (name);


--
-- Name: config worker_group_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.config
    ADD CONSTRAINT worker_group_config_pkey PRIMARY KEY (name);


--
-- Name: worker_group_job_stats worker_group_job_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_group_job_stats
    ADD CONSTRAINT worker_group_job_stats_pkey PRIMARY KEY (hour, worker_group, script_lang, workspace_id);


--
-- Name: worker_ping worker_ping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_ping
    ADD CONSTRAINT worker_ping_pkey PRIMARY KEY (worker);


--
-- Name: workspace_dependencies workspace_dependencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_dependencies
    ADD CONSTRAINT workspace_dependencies_pkey PRIMARY KEY (id);


--
-- Name: workspace_diff_full_scan workspace_diff_full_scan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_diff_full_scan
    ADD CONSTRAINT workspace_diff_full_scan_pkey PRIMARY KEY (source_workspace_id, fork_workspace_id);


--
-- Name: workspace_diff workspace_diff_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_diff
    ADD CONSTRAINT workspace_diff_pkey PRIMARY KEY (source_workspace_id, fork_workspace_id, path, kind);


--
-- Name: workspace_env workspace_env_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_env
    ADD CONSTRAINT workspace_env_pkey PRIMARY KEY (workspace_id, name);


--
-- Name: workspace_fork_deployment_request_assignee workspace_fork_deployment_request_assignee_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_fork_deployment_request_assignee
    ADD CONSTRAINT workspace_fork_deployment_request_assignee_pkey PRIMARY KEY (request_id, username);


--
-- Name: workspace_fork_deployment_request_comment workspace_fork_deployment_request_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_fork_deployment_request_comment
    ADD CONSTRAINT workspace_fork_deployment_request_comment_pkey PRIMARY KEY (id);


--
-- Name: workspace_fork_deployment_request workspace_fork_deployment_request_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_fork_deployment_request
    ADD CONSTRAINT workspace_fork_deployment_request_pkey PRIMARY KEY (id);


--
-- Name: workspace_integrations workspace_integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_integrations
    ADD CONSTRAINT workspace_integrations_pkey PRIMARY KEY (workspace_id, service_name);


--
-- Name: workspace_invite workspace_invite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invite
    ADD CONSTRAINT workspace_invite_pkey PRIMARY KEY (workspace_id, email);


--
-- Name: workspace_key workspace_key_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_key
    ADD CONSTRAINT workspace_key_pkey PRIMARY KEY (workspace_id, kind);


--
-- Name: workspace_multipart_inflight workspace_multipart_inflight_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_multipart_inflight
    ADD CONSTRAINT workspace_multipart_inflight_pkey PRIMARY KEY (workspace_id, upload_id, part_id);


--
-- Name: workspace workspace_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace
    ADD CONSTRAINT workspace_pkey PRIMARY KEY (id);


--
-- Name: workspace_protection_rule workspace_protection_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_protection_rule
    ADD CONSTRAINT workspace_protection_rule_pkey PRIMARY KEY (workspace_id, name);


--
-- Name: workspace_settings workspace_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_settings
    ADD CONSTRAINT workspace_settings_pkey PRIMARY KEY (workspace_id);


--
-- Name: workspace_shared_ui workspace_shared_ui_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_shared_ui
    ADD CONSTRAINT workspace_shared_ui_pkey PRIMARY KEY (workspace_id);


--
-- Name: workspace_storage_usage workspace_storage_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_storage_usage
    ADD CONSTRAINT workspace_storage_usage_pkey PRIMARY KEY (workspace_id, storage);


--
-- Name: ws_specific ws_specific_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ws_specific
    ADD CONSTRAINT ws_specific_pkey PRIMARY KEY (workspace_id, item_kind, path);


--
-- Name: zombie_job_counter zombie_job_counter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zombie_job_counter
    ADD CONSTRAINT zombie_job_counter_pkey PRIMARY KEY (job_id);


--
-- Name: alerts_by_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX alerts_by_workspace ON public.alerts USING btree (workspace_id);


--
-- Name: app_extra_perms; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX app_extra_perms ON public.app USING gin (extra_perms);


--
-- Name: app_workspace_with_hash_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX app_workspace_with_hash_unique_idx ON public.workspace_runnable_dependencies USING btree (app_path, runnable_path, script_hash, runnable_is_flow, workspace_id) WHERE (script_hash IS NOT NULL);


--
-- Name: app_workspace_without_hash_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX app_workspace_without_hash_unique_idx ON public.workspace_runnable_dependencies USING btree (app_path, runnable_path, runnable_is_flow, workspace_id) WHERE (script_hash IS NULL);


--
-- Name: ix_audit_partitioned_timestamps; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_audit_partitioned_timestamps ON ONLY public.audit_partitioned USING btree ("timestamp" DESC);


--
-- Name: audit_20260815_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260815_timestamp_idx ON public.audit_20260815 USING btree ("timestamp" DESC);


--
-- Name: idx_audit_partitioned_recent_login_activities; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_partitioned_recent_login_activities ON ONLY public.audit_partitioned USING btree ("timestamp", username) WHERE ((operation)::text = ANY ((ARRAY['users.login'::character varying, 'oauth.login'::character varying, 'users.token.refresh'::character varying])::text[]));


--
-- Name: audit_20260815_timestamp_username_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260815_timestamp_username_idx ON public.audit_20260815 USING btree ("timestamp", username) WHERE ((operation)::text = ANY ((ARRAY['users.login'::character varying, 'oauth.login'::character varying, 'users.token.refresh'::character varying])::text[]));


--
-- Name: idx_audit_partitioned_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_partitioned_workspace ON ONLY public.audit_partitioned USING btree (workspace_id, "timestamp" DESC);


--
-- Name: audit_20260815_workspace_id_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260815_workspace_id_timestamp_idx ON public.audit_20260815 USING btree (workspace_id, "timestamp" DESC);


--
-- Name: audit_20260816_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260816_timestamp_idx ON public.audit_20260816 USING btree ("timestamp" DESC);


--
-- Name: audit_20260816_timestamp_username_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260816_timestamp_username_idx ON public.audit_20260816 USING btree ("timestamp", username) WHERE ((operation)::text = ANY ((ARRAY['users.login'::character varying, 'oauth.login'::character varying, 'users.token.refresh'::character varying])::text[]));


--
-- Name: audit_20260816_workspace_id_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260816_workspace_id_timestamp_idx ON public.audit_20260816 USING btree (workspace_id, "timestamp" DESC);


--
-- Name: audit_20260817_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260817_timestamp_idx ON public.audit_20260817 USING btree ("timestamp" DESC);


--
-- Name: audit_20260817_timestamp_username_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260817_timestamp_username_idx ON public.audit_20260817 USING btree ("timestamp", username) WHERE ((operation)::text = ANY ((ARRAY['users.login'::character varying, 'oauth.login'::character varying, 'users.token.refresh'::character varying])::text[]));


--
-- Name: audit_20260817_workspace_id_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260817_workspace_id_timestamp_idx ON public.audit_20260817 USING btree (workspace_id, "timestamp" DESC);


--
-- Name: audit_20260818_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260818_timestamp_idx ON public.audit_20260818 USING btree ("timestamp" DESC);


--
-- Name: audit_20260818_timestamp_username_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260818_timestamp_username_idx ON public.audit_20260818 USING btree ("timestamp", username) WHERE ((operation)::text = ANY ((ARRAY['users.login'::character varying, 'oauth.login'::character varying, 'users.token.refresh'::character varying])::text[]));


--
-- Name: audit_20260818_workspace_id_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_20260818_workspace_id_timestamp_idx ON public.audit_20260818 USING btree (workspace_id, "timestamp" DESC);


--
-- Name: autoscaling_event_applied_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX autoscaling_event_applied_at_idx ON public.autoscaling_event USING btree (applied_at);


--
-- Name: autoscaling_event_worker_group_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX autoscaling_event_worker_group_idx ON public.autoscaling_event USING btree (worker_group, applied_at);


--
-- Name: concurrency_key_ended_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX concurrency_key_ended_at_idx ON public.concurrency_key USING btree (key, ended_at DESC);


--
-- Name: concurrency_key_ended_at_only_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX concurrency_key_ended_at_only_idx ON public.concurrency_key USING btree (ended_at);


--
-- Name: dbt_edge_editor_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dbt_edge_editor_key ON public.dbt_edge USING btree (workspace_id, job_id, parent_unique_id, child_unique_id) WHERE (script_hash IS NULL);


--
-- Name: dbt_edge_versioned_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dbt_edge_versioned_key ON public.dbt_edge USING btree (workspace_id, script_path, script_hash, job_id, parent_unique_id, child_unique_id) WHERE (script_hash IS NOT NULL);


--
-- Name: dbt_graph_snapshot_editor_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dbt_graph_snapshot_editor_key ON public.dbt_graph_snapshot USING btree (workspace_id, job_id) WHERE (script_hash IS NULL);


--
-- Name: dbt_graph_snapshot_versioned_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dbt_graph_snapshot_versioned_key ON public.dbt_graph_snapshot USING btree (workspace_id, script_path, script_hash, job_id) WHERE (script_hash IS NOT NULL);


--
-- Name: dbt_node_editor_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dbt_node_editor_key ON public.dbt_node USING btree (workspace_id, job_id, unique_id) WHERE (script_hash IS NULL);


--
-- Name: dbt_node_versioned_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dbt_node_versioned_key ON public.dbt_node USING btree (workspace_id, script_path, script_hash, job_id, unique_id) WHERE (script_hash IS NOT NULL);


--
-- Name: dependency_map_imported_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dependency_map_imported_path_idx ON public.dependency_map USING btree (workspace_id, imported_path);


--
-- Name: dependency_map_importer_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dependency_map_importer_path_idx ON public.dependency_map USING btree (workspace_id, importer_path);


--
-- Name: deployment_metadata_app; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX deployment_metadata_app ON public.deployment_metadata USING btree (workspace_id, path, app_version) WHERE (app_version IS NOT NULL);


--
-- Name: deployment_metadata_flow; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX deployment_metadata_flow ON public.deployment_metadata USING btree (workspace_id, path, flow_version) WHERE (flow_version IS NOT NULL);


--
-- Name: deployment_metadata_script; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX deployment_metadata_script ON public.deployment_metadata USING btree (workspace_id, script_hash) WHERE (script_hash IS NOT NULL);


--
-- Name: draft_kind_user_listing_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX draft_kind_user_listing_idx ON public.draft USING btree (workspace_id, typ, email);


--
-- Name: draft_pkey_legacy; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX draft_pkey_legacy ON public.draft USING btree (workspace_id, path, typ) WHERE (email IS NULL);


--
-- Name: draft_pkey_with_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX draft_pkey_with_user ON public.draft USING btree (workspace_id, path, typ, email) WHERE (email IS NOT NULL);


--
-- Name: draft_user_listing_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX draft_user_listing_idx ON public.draft USING btree (workspace_id, email, path) WHERE (email IS NOT NULL);


--
-- Name: draft_workspace_path_typ_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX draft_workspace_path_typ_idx ON public.draft USING btree (workspace_id, path, typ);


--
-- Name: flow_extra_perms; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX flow_extra_perms ON public.flow USING gin (extra_perms);


--
-- Name: flow_node_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX flow_node_hash ON public.flow_node USING btree (hash);


--
-- Name: flow_workspace_runnable_path_is_flow_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX flow_workspace_runnable_path_is_flow_idx ON public.workspace_runnable_dependencies USING btree (runnable_path, runnable_is_flow, workspace_id);


--
-- Name: flow_workspace_with_hash_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX flow_workspace_with_hash_unique_idx ON public.workspace_runnable_dependencies USING btree (flow_path, runnable_path, script_hash, runnable_is_flow, workspace_id) WHERE (script_hash IS NOT NULL);


--
-- Name: flow_workspace_without_hash_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX flow_workspace_without_hash_unique_idx ON public.workspace_runnable_dependencies USING btree (flow_path, runnable_path, runnable_is_flow, workspace_id) WHERE (script_hash IS NULL);


--
-- Name: folder_extra_perms; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX folder_extra_perms ON public.folder USING gin (extra_perms);


--
-- Name: folder_owners; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX folder_owners ON public.folder USING gin (owners);


--
-- Name: group_extra_perms; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX group_extra_perms ON public.group_ USING gin (extra_perms);


--
-- Name: healthchecks_check_type_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX healthchecks_check_type_created_at ON public.healthchecks USING btree (check_type, created_at);


--
-- Name: idx_account_mcp_server_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_account_mcp_server_url ON public.account USING btree (mcp_server_url) WHERE (mcp_server_url IS NOT NULL);


--
-- Name: idx_agent_token_blacklist_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_agent_token_blacklist_expires_at ON public.agent_token_blacklist USING btree (expires_at);


--
-- Name: idx_amqp_trigger_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_amqp_trigger_labels ON public.amqp_trigger USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_app_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_labels ON public.app USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_app_owner_prefix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_app_owner_prefix ON public.app USING btree (workspace_id, path text_pattern_ops);


--
-- Name: idx_asset_job_pruning; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asset_job_pruning ON public.asset USING btree (workspace_id, path, kind, created_at DESC) WHERE (usage_kind = 'job'::public.asset_usage_kind);


--
-- Name: idx_asset_usage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asset_usage ON public.asset USING btree (workspace_id, usage_path, usage_kind);


--
-- Name: idx_asset_ws_path_kind_recent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asset_ws_path_kind_recent ON public.asset USING btree (workspace_id, path, kind, created_at DESC, id DESC) INCLUDE (usage_kind, usage_path);


--
-- Name: idx_audit_recent_login_activities; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_recent_login_activities ON public.audit USING btree ("timestamp", username) WHERE ((operation)::text = ANY ((ARRAY['users.login'::character varying, 'oauth.login'::character varying, 'users.token.refresh'::character varying])::text[]));


--
-- Name: idx_azure_trigger_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_azure_trigger_labels ON public.azure_trigger USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_ci_test_ref_test_script; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ci_test_ref_test_script ON public.ci_test_reference USING btree (workspace_id, test_script_path);


--
-- Name: idx_ci_test_ref_tested_item; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ci_test_ref_tested_item ON public.ci_test_reference USING btree (workspace_id, tested_item_path, tested_item_kind);


--
-- Name: idx_ci_test_ref_wildcards; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ci_test_ref_wildcards ON public.ci_test_reference USING btree (workspace_id, tested_item_kind) WHERE has_wildcard;


--
-- Name: idx_conversation_message_conversation_created_seq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversation_message_conversation_created_seq ON public.flow_conversation_message USING btree (conversation_id, created_seq);


--
-- Name: idx_data_metric_folder; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_data_metric_folder ON public.data_metric USING btree (workspace_id, script_path text_pattern_ops);


--
-- Name: idx_data_metric_page; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_data_metric_page ON public.data_metric USING btree (workspace_id, table_path, kind, name, script_path);


--
-- Name: idx_data_metric_table; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_data_metric_table ON public.data_metric USING btree (workspace_id, table_path);


--
-- Name: idx_dbt_edge_run_age; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dbt_edge_run_age ON public.dbt_edge USING btree (ingested_at) WHERE (job_id <> '00000000-0000-0000-0000-000000000000'::uuid);


--
-- Name: idx_dbt_graph_snapshot_age; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dbt_graph_snapshot_age ON public.dbt_graph_snapshot USING btree (ingested_at) WHERE (job_id <> '00000000-0000-0000-0000-000000000000'::uuid);


--
-- Name: idx_dbt_graph_snapshot_editor_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dbt_graph_snapshot_editor_path ON public.dbt_graph_snapshot USING btree (workspace_id, script_path, permissioned_as, ingested_at) WHERE (script_hash IS NULL);


--
-- Name: idx_dbt_graph_snapshot_job; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dbt_graph_snapshot_job ON public.dbt_graph_snapshot USING btree (workspace_id, job_id);


--
-- Name: idx_dbt_node_asset_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dbt_node_asset_path ON public.dbt_node USING btree (workspace_id, asset_path) WHERE (asset_path IS NOT NULL);


--
-- Name: idx_dbt_node_job; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dbt_node_job ON public.dbt_node USING btree (job_id) WHERE (job_id <> '00000000-0000-0000-0000-000000000000'::uuid);


--
-- Name: idx_dbt_node_run_age; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dbt_node_run_age ON public.dbt_node USING btree (ingested_at) WHERE (job_id <> '00000000-0000-0000-0000-000000000000'::uuid);


--
-- Name: idx_dbt_run_progress_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dbt_run_progress_updated_at ON public.dbt_run_progress USING btree (updated_at);


--
-- Name: idx_debounce_key_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_debounce_key_job_id ON public.debounce_key USING btree (job_id);


--
-- Name: idx_dispatch_event_producer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dispatch_event_producer ON public.dispatch_event USING btree (producer_job_id, id);


--
-- Name: idx_dispatch_event_subscriber; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dispatch_event_subscriber ON public.dispatch_event USING btree (workspace_id, subscriber_path text_pattern_ops, created_at DESC);


--
-- Name: idx_email_trigger_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_trigger_labels ON public.email_trigger USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_feature_usage_day; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feature_usage_day ON public.feature_usage USING btree (day);


--
-- Name: idx_flow_conversation_workspace_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flow_conversation_workspace_path ON public.flow_conversation USING btree (workspace_id, flow_path, updated_at DESC);


--
-- Name: idx_flow_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flow_labels ON public.flow USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_flow_owner_prefix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flow_owner_prefix ON public.flow USING btree (workspace_id, path text_pattern_ops) WHERE (archived = false);


--
-- Name: idx_folder_perm_history_workspace_folder; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_folder_perm_history_workspace_folder ON public.folder_permission_history USING btree (workspace_id, folder_name, id DESC);


--
-- Name: idx_gcp_trigger_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gcp_trigger_labels ON public.gcp_trigger USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_group_perm_history_workspace_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_group_perm_history_workspace_group ON public.group_permission_history USING btree (workspace_id, group_name, id DESC);


--
-- Name: idx_http_trigger_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_http_trigger_labels ON public.http_trigger USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_job_delete_schedule_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_job_delete_schedule_delete_at ON public.job_delete_schedule USING btree (delete_at);


--
-- Name: idx_job_v2_job_root_by_path_2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_job_v2_job_root_by_path_2 ON public.v2_job USING btree (workspace_id, runnable_path) WHERE (parent_job IS NULL);


--
-- Name: idx_kafka_pending_commits_trigger; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_kafka_pending_commits_trigger ON public.kafka_pending_commits USING btree (workspace_id, kafka_trigger_path);


--
-- Name: idx_kafka_trigger_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_kafka_trigger_labels ON public.kafka_trigger USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_macro_definition_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_macro_definition_provider ON public.macro_definition USING btree (workspace_id, provider_path);


--
-- Name: idx_macro_usage_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_macro_usage_name ON public.macro_usage USING btree (workspace_id, macro_name);


--
-- Name: idx_materialized_partition_asset_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_materialized_partition_asset_status ON public.materialized_partition USING btree (workspace_id, asset_kind, asset_path, status);


--
-- Name: idx_materialized_partition_job; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_materialized_partition_job ON public.materialized_partition USING btree (workspace_id, job_id) WHERE (job_id IS NOT NULL);


--
-- Name: idx_mcp_oauth_client_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mcp_oauth_client_expires ON public.mcp_oauth_client USING btree (client_secret_expires_at);


--
-- Name: idx_mcp_oauth_refresh_token_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mcp_oauth_refresh_token_expires ON public.mcp_oauth_refresh_token USING btree (expires_at);


--
-- Name: idx_mcp_oauth_refresh_token_family; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mcp_oauth_refresh_token_family ON public.mcp_oauth_refresh_token USING btree (token_family);


--
-- Name: idx_mcp_oauth_refresh_token_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mcp_oauth_refresh_token_token ON public.mcp_oauth_refresh_token USING btree (refresh_token);


--
-- Name: idx_mcp_oauth_server_code_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mcp_oauth_server_code_expires ON public.mcp_oauth_server_code USING btree (expires_at);


--
-- Name: idx_metrics_id_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_metrics_id_created_at ON public.metrics USING btree (id, created_at DESC) WHERE ((id)::text ~~ 'queue_%'::text);


--
-- Name: idx_mqtt_trigger_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mqtt_trigger_labels ON public.mqtt_trigger USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_native_trigger_script_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_native_trigger_script_path ON public.native_trigger USING btree (workspace_id, script_path, is_flow);


--
-- Name: idx_native_trigger_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_native_trigger_workspace ON public.native_trigger USING btree (workspace_id);


--
-- Name: idx_nats_trigger_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nats_trigger_labels ON public.nats_trigger USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_postgres_trigger_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_postgres_trigger_labels ON public.postgres_trigger USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_raw_app_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_raw_app_labels ON public.raw_app USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_raw_script_temp_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_raw_script_temp_created_at ON public.raw_script_temp USING btree (created_at);


--
-- Name: idx_resource_cache_expire; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_resource_cache_expire ON public.resource USING btree (to_timestamp((((value ->> 'expire'::text))::integer)::double precision)) WHERE ((resource_type)::text = 'cache'::text);


--
-- Name: idx_resource_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_resource_labels ON public.resource USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_schedule_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schedule_labels ON public.schedule USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_script_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_script_labels ON public.script USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_script_owner_prefix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_script_owner_prefix ON public.script USING btree (workspace_id, path text_pattern_ops) INCLUDE (auto_kind) WHERE (archived = false);


--
-- Name: idx_script_pipeline_freshness_scan; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_script_pipeline_freshness_scan ON public.script USING btree (workspace_id, path, created_at DESC) WHERE (((auto_kind)::text = 'pipeline'::text) AND (archived = false) AND (deleted = false));


--
-- Name: idx_script_pipeline_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_script_pipeline_path ON public.script USING btree (workspace_id, path text_pattern_ops) WHERE (((auto_kind)::text = 'pipeline'::text) AND (archived = false) AND (deleted = false));


--
-- Name: idx_script_trigger_ref; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_script_trigger_ref ON public.script_trigger USING btree (workspace_id, trigger_kind, trigger_ref);


--
-- Name: idx_script_trigger_runnable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_script_trigger_runnable ON public.script_trigger USING btree (workspace_id, runnable_kind, runnable_path);


--
-- Name: idx_sqs_trigger_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sqs_trigger_labels ON public.sqs_trigger USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_token_expiry_notification_expiration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_token_expiry_notification_expiration ON public.token_expiry_notification USING btree (expiration);


--
-- Name: idx_token_plaintext; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_token_plaintext ON public.token USING btree (token) WHERE (token IS NOT NULL);


--
-- Name: idx_token_prefix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_token_prefix ON public.token USING btree (token_prefix);


--
-- Name: idx_trashbin_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trashbin_expires_at ON public.trashbin USING btree (expires_at);


--
-- Name: idx_trashbin_workspace_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trashbin_workspace_kind ON public.trashbin USING btree (workspace_id, item_kind);


--
-- Name: idx_trigger_history_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trigger_history_workspace_id ON public.trigger_history USING btree (workspace_id, id DESC);


--
-- Name: idx_trigger_history_workspace_kind_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trigger_history_workspace_kind_path ON public.trigger_history USING btree (workspace_id, trigger_kind, path, id DESC);


--
-- Name: idx_unique_ext_jwt_token_last_used_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_unique_ext_jwt_token_last_used_at ON public.unique_ext_jwt_token USING btree (last_used_at);


--
-- Name: idx_usr_added_via; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usr_added_via ON public.usr USING gin (added_via);


--
-- Name: idx_v2_job_debounce_batch_consumed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_v2_job_debounce_batch_consumed_at ON public.v2_job_debounce_batch USING btree (consumed_at) WHERE (consumed_at IS NOT NULL);


--
-- Name: idx_v2_job_debounce_batch_debounce_batch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_v2_job_debounce_batch_debounce_batch ON public.v2_job_debounce_batch USING btree (debounce_batch);


--
-- Name: idx_variable_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_variable_labels ON public.variable USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_volume_last_used; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_volume_last_used ON public.volume USING btree (workspace_id, last_used_at);


--
-- Name: idx_websocket_trigger_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_websocket_trigger_labels ON public.websocket_trigger USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: idx_workspace_integrations_service; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspace_integrations_service ON public.workspace_integrations USING btree (service_name);


--
-- Name: idx_workspace_integrations_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspace_integrations_workspace ON public.workspace_integrations USING btree (workspace_id);


--
-- Name: idx_workspace_multipart_inflight_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspace_multipart_inflight_created_at ON public.workspace_multipart_inflight USING btree (created_at);


--
-- Name: idx_workspace_settings_auto_invite; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspace_settings_auto_invite ON public.workspace_settings USING gin (auto_invite);


--
-- Name: index_app_on_workspace_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_app_on_workspace_name ON public.app USING btree (workspace_id, lower(COALESCE(NULLIF((summary)::text, ''::text), (path)::text)));


--
-- Name: index_flow_on_workspace_edited_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flow_on_workspace_edited_at ON public.flow USING btree (workspace_id, archived, edited_at DESC);


--
-- Name: index_flow_on_workspace_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flow_on_workspace_name ON public.flow USING btree (workspace_id, archived, lower(COALESCE(NULLIF(summary, ''::text), (path)::text)));


--
-- Name: index_flow_version_path_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flow_version_path_created_at ON public.flow_version USING btree (path, created_at);


--
-- Name: index_magic_link_exp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_magic_link_exp ON public.magic_link USING btree (expiration);


--
-- Name: index_resource_version_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_version_path ON public.resource_version USING btree (workspace_id, path, id DESC);


--
-- Name: index_script_on_path_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_script_on_path_created_at ON public.script USING btree (workspace_id, path, created_at DESC);


--
-- Name: index_script_on_workspace_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_script_on_workspace_created_at ON public.script USING btree (workspace_id, archived, created_at DESC);


--
-- Name: index_script_on_workspace_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_script_on_workspace_name ON public.script USING btree (workspace_id, archived, lower(COALESCE(NULLIF(summary, ''::text), (path)::text)));


--
-- Name: index_token_exp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_token_exp ON public.token USING btree (expiration);


--
-- Name: index_usr_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_usr_email ON public.usr USING btree (email);


--
-- Name: ix_audit_timestamps; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_audit_timestamps ON public.audit USING btree ("timestamp" DESC);


--
-- Name: ix_job_completed_completed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_job_completed_completed_at ON public.v2_job_completed USING btree (completed_at DESC);


--
-- Name: ix_job_root_job_index_by_path_2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_job_root_job_index_by_path_2 ON public.v2_job USING btree (workspace_id, runnable_path, created_at DESC) WHERE (parent_job IS NULL);


--
-- Name: ix_job_workspace_id_completed_at_all; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_job_workspace_id_completed_at_all ON public.v2_job_completed USING btree (workspace_id, completed_at DESC);


--
-- Name: ix_job_workspace_id_created_at_new_3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_job_workspace_id_created_at_new_3 ON public.v2_job USING btree (workspace_id, created_at DESC);


--
-- Name: ix_job_workspace_id_created_at_new_5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_job_workspace_id_created_at_new_5 ON public.v2_job USING btree (workspace_id, created_at DESC) WHERE ((kind = ANY (ARRAY['preview'::public.job_kind, 'flowpreview'::public.job_kind])) AND (parent_job IS NULL));


--
-- Name: ix_job_workspace_id_created_at_new_8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_job_workspace_id_created_at_new_8 ON public.v2_job USING btree (workspace_id, created_at DESC) WHERE ((kind = 'deploymentcallback'::public.job_kind) AND (parent_job IS NULL));


--
-- Name: ix_job_workspace_id_created_at_new_9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_job_workspace_id_created_at_new_9 ON public.v2_job USING btree (workspace_id, created_at DESC) WHERE ((kind = ANY (ARRAY['dependencies'::public.job_kind, 'flowdependencies'::public.job_kind, 'appdependencies'::public.job_kind])) AND (parent_job IS NULL));


--
-- Name: ix_resume_job_flow; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_resume_job_flow ON public.resume_job USING btree (flow);


--
-- Name: ix_v2_job_completed_failure_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_v2_job_completed_failure_workspace ON public.v2_job_completed USING btree (workspace_id, completed_at DESC) WHERE (status = ANY (ARRAY['failure'::public.job_status, 'canceled'::public.job_status]));


--
-- Name: ix_v2_job_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_v2_job_labels ON public.v2_job USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: ix_v2_job_parent_job; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_v2_job_parent_job ON public.v2_job USING btree (parent_job, created_at DESC) WHERE (parent_job IS NOT NULL);


--
-- Name: ix_v2_job_workspace_id_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_v2_job_workspace_id_created_at ON public.v2_job USING btree (workspace_id, created_at DESC) WHERE ((kind = ANY (ARRAY['script'::public.job_kind, 'flow'::public.job_kind, 'singlestepflow'::public.job_kind])) AND (parent_job IS NULL));


--
-- Name: job_stats_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_stats_id ON public.job_stats USING btree (job_id);


--
-- Name: labeled_jobs_on_jobs; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX labeled_jobs_on_jobs ON public.v2_job_completed USING gin (((result -> 'wm_labels'::text))) WHERE (result ? 'wm_labels'::text);


--
-- Name: log_file_log_ts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX log_file_log_ts_idx ON public.log_file USING btree (log_ts);


--
-- Name: metrics_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX metrics_key_idx ON public.metrics USING btree (id);


--
-- Name: metrics_sort_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX metrics_sort_idx ON public.metrics USING btree (created_at DESC);


--
-- Name: notify_event_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notify_event_created_at_idx ON public.notify_event USING btree (created_at);


--
-- Name: one_non_archived_per_name_language_constraint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX one_non_archived_per_name_language_constraint ON public.workspace_dependencies USING btree (name, language, workspace_id) WHERE ((archived = false) AND (name IS NOT NULL));


--
-- Name: one_non_archived_per_null_name_language_constraint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX one_non_archived_per_null_name_language_constraint ON public.workspace_dependencies USING btree (language, workspace_id) WHERE ((archived = false) AND (name IS NULL));


--
-- Name: otel_traces_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX otel_traces_time_idx ON public.otel_traces USING btree (start_time_unix_nano);


--
-- Name: otel_traces_trace_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX otel_traces_trace_time_idx ON public.otel_traces USING btree (trace_id, start_time_unix_nano);


--
-- Name: queue_sort_v2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX queue_sort_v2 ON public.v2_job_queue USING btree (priority DESC NULLS LAST, scheduled_for, tag) WHERE (running = false);


--
-- Name: queue_suspended; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX queue_suspended ON public.v2_job_queue USING btree (priority DESC NULLS LAST, created_at, suspend_until, suspend, tag) WHERE (suspend_until IS NOT NULL);


--
-- Name: resource_extra_perms; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resource_extra_perms ON public.resource USING gin (extra_perms);


--
-- Name: root_queue_index_by_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX root_queue_index_by_path ON public.v2_job_queue USING btree (workspace_id, created_at);


--
-- Name: schedule_extra_perms; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX schedule_extra_perms ON public.schedule USING gin (extra_perms);


--
-- Name: script_extra_perms; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX script_extra_perms ON public.script USING gin (extra_perms);


--
-- Name: script_not_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX script_not_archived ON public.script USING btree (workspace_id, path, created_at DESC) WHERE (archived = false);


--
-- Name: unique_subscription_per_azure_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_subscription_per_azure_scope ON public.azure_trigger USING btree (subscription_name, scope_resource_id, workspace_id);


--
-- Name: unique_subscription_per_gcp_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_subscription_per_gcp_resource ON public.gcp_trigger USING btree (subscription_id, gcp_resource_path, workspace_id);


--
-- Name: v2_job_queue_suspend; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX v2_job_queue_suspend ON public.v2_job_queue USING btree (workspace_id, suspend) WHERE (suspend > 0);


--
-- Name: variable_extra_perms; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX variable_extra_perms ON public.variable USING gin (extra_perms);


--
-- Name: worker_group_job_stats_hour_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX worker_group_job_stats_hour_idx ON public.worker_group_job_stats USING btree (hour DESC);


--
-- Name: worker_group_job_stats_worker_group_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX worker_group_job_stats_worker_group_idx ON public.worker_group_job_stats USING btree (worker_group, hour DESC);


--
-- Name: worker_group_job_stats_workspace_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX worker_group_job_stats_workspace_idx ON public.worker_group_job_stats USING btree (workspace_id, hour DESC);


--
-- Name: worker_ping_on_ping_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX worker_ping_on_ping_at ON public.worker_ping USING btree (ping_at);


--
-- Name: workspace_canonical_dev_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX workspace_canonical_dev_idx ON public.workspace USING btree (parent_workspace_id) WHERE (is_dev_workspace AND (deleted = false));


--
-- Name: workspace_dependencies_id_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workspace_dependencies_id_workspace ON public.workspace_dependencies USING btree (id, workspace_id);


--
-- Name: workspace_dependencies_workspace_archived_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workspace_dependencies_workspace_archived_idx ON public.workspace_dependencies USING btree (workspace_id, archived) WHERE (archived = false);


--
-- Name: workspace_dependencies_workspace_lang_name_archived_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workspace_dependencies_workspace_lang_name_archived_idx ON public.workspace_dependencies USING btree (workspace_id, language, name, archived);


--
-- Name: workspace_fork_deployment_request_comment_anchor_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workspace_fork_deployment_request_comment_anchor_idx ON public.workspace_fork_deployment_request_comment USING btree (request_id, anchor_kind, anchor_path) WHERE (anchor_kind IS NOT NULL);


--
-- Name: workspace_fork_deployment_request_comment_request_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workspace_fork_deployment_request_comment_request_idx ON public.workspace_fork_deployment_request_comment USING btree (request_id);


--
-- Name: workspace_fork_deployment_request_fork_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workspace_fork_deployment_request_fork_idx ON public.workspace_fork_deployment_request USING btree (fork_workspace_id, closed_at);


--
-- Name: workspace_fork_deployment_request_open_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX workspace_fork_deployment_request_open_unique ON public.workspace_fork_deployment_request USING btree (source_workspace_id, fork_workspace_id) WHERE (closed_at IS NULL);


--
-- Name: workspace_parent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workspace_parent_idx ON public.workspace USING btree (parent_workspace_id) WHERE (parent_workspace_id IS NOT NULL);


--
-- Name: audit_20260815_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_partitioned_pkey ATTACH PARTITION public.audit_20260815_pkey;


--
-- Name: audit_20260815_timestamp_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.ix_audit_partitioned_timestamps ATTACH PARTITION public.audit_20260815_timestamp_idx;


--
-- Name: audit_20260815_timestamp_username_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_partitioned_recent_login_activities ATTACH PARTITION public.audit_20260815_timestamp_username_idx;


--
-- Name: audit_20260815_workspace_id_timestamp_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_partitioned_workspace ATTACH PARTITION public.audit_20260815_workspace_id_timestamp_idx;


--
-- Name: audit_20260816_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_partitioned_pkey ATTACH PARTITION public.audit_20260816_pkey;


--
-- Name: audit_20260816_timestamp_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.ix_audit_partitioned_timestamps ATTACH PARTITION public.audit_20260816_timestamp_idx;


--
-- Name: audit_20260816_timestamp_username_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_partitioned_recent_login_activities ATTACH PARTITION public.audit_20260816_timestamp_username_idx;


--
-- Name: audit_20260816_workspace_id_timestamp_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_partitioned_workspace ATTACH PARTITION public.audit_20260816_workspace_id_timestamp_idx;


--
-- Name: audit_20260817_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_partitioned_pkey ATTACH PARTITION public.audit_20260817_pkey;


--
-- Name: audit_20260817_timestamp_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.ix_audit_partitioned_timestamps ATTACH PARTITION public.audit_20260817_timestamp_idx;


--
-- Name: audit_20260817_timestamp_username_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_partitioned_recent_login_activities ATTACH PARTITION public.audit_20260817_timestamp_username_idx;


--
-- Name: audit_20260817_workspace_id_timestamp_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_partitioned_workspace ATTACH PARTITION public.audit_20260817_workspace_id_timestamp_idx;


--
-- Name: audit_20260818_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.audit_partitioned_pkey ATTACH PARTITION public.audit_20260818_pkey;


--
-- Name: audit_20260818_timestamp_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.ix_audit_partitioned_timestamps ATTACH PARTITION public.audit_20260818_timestamp_idx;


--
-- Name: audit_20260818_timestamp_username_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_partitioned_recent_login_activities ATTACH PARTITION public.audit_20260818_timestamp_username_idx;


--
-- Name: audit_20260818_workspace_id_timestamp_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_audit_partitioned_workspace ATTACH PARTITION public.audit_20260818_workspace_id_timestamp_idx;


--
-- Name: app app_policy_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER app_policy_change_trigger AFTER UPDATE OF policy ON public.app FOR EACH ROW WHEN ((old.policy IS DISTINCT FROM new.policy)) EXECUTE FUNCTION public.notify_app_policy_change();


--
-- Name: app app_policy_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER app_policy_delete_trigger AFTER DELETE ON public.app FOR EACH ROW EXECUTE FUNCTION public.notify_app_policy_change();


--
-- Name: global_settings audit_logs_s3_anchor_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_logs_s3_anchor_trigger AFTER INSERT OR UPDATE OF value ON public.global_settings FOR EACH ROW WHEN (((new.name)::text = 'store_audit_logs_s3'::text)) EXECUTE FUNCTION public.audit_logs_s3_anchor_on_enable();


--
-- Name: http_trigger check_route_path_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_route_path_change BEFORE UPDATE ON public.http_trigger FOR EACH ROW EXECUTE FUNCTION public.prevent_route_path_change();


--
-- Name: flow flow_versions_append_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER flow_versions_append_trigger AFTER UPDATE ON public.flow FOR EACH ROW WHEN ((new.versions[array_upper(new.versions, 1)] IS DISTINCT FROM old.versions[array_upper(old.versions, 1)])) EXECUTE FUNCTION public.notify_runnable_version_change('flow');


--
-- Name: http_trigger http_trigger_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER http_trigger_change_trigger AFTER INSERT OR DELETE OR UPDATE ON public.http_trigger FOR EACH ROW EXECUTE FUNCTION public.notify_http_trigger_change();


--
-- Name: config notify_config_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify_config_change AFTER INSERT OR UPDATE ON public.config FOR EACH ROW EXECUTE FUNCTION public.notify_config_change();


--
-- Name: global_settings notify_global_setting_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify_global_setting_change AFTER INSERT OR UPDATE ON public.global_settings FOR EACH ROW EXECUTE FUNCTION public.notify_global_setting_change();


--
-- Name: global_settings notify_global_setting_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify_global_setting_delete AFTER DELETE ON public.global_settings FOR EACH ROW EXECUTE FUNCTION public.notify_global_setting_delete();


--
-- Name: resource record_resource_version_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER record_resource_version_insert_trigger AFTER INSERT ON public.resource FOR EACH ROW WHEN (((new.resource_type)::text <> ALL ((ARRAY['state'::character varying, 'cache'::character varying])::text[]))) EXECUTE FUNCTION public.record_resource_version();


--
-- Name: resource record_resource_version_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER record_resource_version_update_trigger AFTER UPDATE ON public.resource FOR EACH ROW WHEN ((((new.resource_type)::text <> ALL ((ARRAY['state'::character varying, 'cache'::character varying])::text[])) AND (new.value IS DISTINCT FROM old.value))) EXECUTE FUNCTION public.record_resource_version();


--
-- Name: script script_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER script_insert_trigger AFTER INSERT ON public.script FOR EACH ROW WHEN ((new.lock IS NOT NULL)) EXECUTE FUNCTION public.notify_runnable_version_change('script');


--
-- Name: script script_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER script_update_trigger AFTER UPDATE OF lock ON public.script FOR EACH ROW EXECUTE FUNCTION public.notify_runnable_version_change('script');


--
-- Name: cloud_workspace_settings team_plan_status_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER team_plan_status_change_trigger AFTER UPDATE OF is_past_due, max_tolerated_executions ON public.cloud_workspace_settings FOR EACH ROW EXECUTE FUNCTION public.notify_team_plan_status_change();


--
-- Name: token token_invalidation_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER token_invalidation_trigger AFTER DELETE ON public.token FOR EACH ROW EXECUTE FUNCTION public.notify_token_invalidation();


--
-- Name: token token_scopes_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER token_scopes_update_trigger AFTER UPDATE OF scopes ON public.token FOR EACH ROW EXECUTE FUNCTION public.notify_token_scopes_change();


--
-- Name: workspace_settings webhook_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER webhook_change_trigger AFTER UPDATE OF webhook ON public.workspace_settings FOR EACH ROW WHEN ((old.webhook IS DISTINCT FROM new.webhook)) EXECUTE FUNCTION public.notify_webhook_change();


--
-- Name: workspace_env workspace_envs_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workspace_envs_change_trigger AFTER INSERT OR DELETE OR UPDATE OF name, value ON public.workspace_env FOR EACH ROW EXECUTE FUNCTION public.notify_workspace_envs_change();


--
-- Name: workspace_key workspace_key_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workspace_key_change_trigger AFTER INSERT OR DELETE OR UPDATE OF key ON public.workspace_key FOR EACH ROW EXECUTE FUNCTION public.notify_workspace_key_change();


--
-- Name: workspace workspace_premium_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workspace_premium_change_trigger AFTER UPDATE OF premium ON public.workspace FOR EACH ROW EXECUTE FUNCTION public.notify_workspace_premium_change();


--
-- Name: workspace_settings workspace_rate_limit_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workspace_rate_limit_change_trigger AFTER UPDATE OF public_app_execution_limit_per_minute ON public.workspace_settings FOR EACH ROW EXECUTE FUNCTION public.notify_workspace_rate_limit_change();


--
-- Name: account account_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: ai_skill ai_skill_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_skill
    ADD CONSTRAINT ai_skill_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: amqp_trigger amqp_trigger_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amqp_trigger
    ADD CONSTRAINT amqp_trigger_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: app_script app_script_app_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_script
    ADD CONSTRAINT app_script_app_fkey FOREIGN KEY (app) REFERENCES public.app(id) ON DELETE CASCADE;


--
-- Name: app_version app_version_flow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_version
    ADD CONSTRAINT app_version_flow_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id) ON DELETE CASCADE;


--
-- Name: app_version_lite app_version_lite_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_version_lite
    ADD CONSTRAINT app_version_lite_id_fkey FOREIGN KEY (id) REFERENCES public.app_version(id) ON DELETE CASCADE;


--
-- Name: app app_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app
    ADD CONSTRAINT app_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: asset asset_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT asset_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: capture_config capture_config_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capture_config
    ADD CONSTRAINT capture_config_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: capture capture_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: ci_test_reference ci_test_reference_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ci_test_reference
    ADD CONSTRAINT ci_test_reference_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: cloud_workspace_settings cloud_workspace_settings_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloud_workspace_settings
    ADD CONSTRAINT cloud_workspace_settings_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: data_metric data_metric_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_metric
    ADD CONSTRAINT data_metric_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: datatable_migrations datatable_migrations_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatable_migrations
    ADD CONSTRAINT datatable_migrations_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: dbt_edge dbt_edge_script_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dbt_edge
    ADD CONSTRAINT dbt_edge_script_fkey FOREIGN KEY (workspace_id, script_hash) REFERENCES public.script(workspace_id, hash) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dbt_edge dbt_edge_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dbt_edge
    ADD CONSTRAINT dbt_edge_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dbt_graph_snapshot dbt_graph_snapshot_script_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dbt_graph_snapshot
    ADD CONSTRAINT dbt_graph_snapshot_script_fkey FOREIGN KEY (workspace_id, script_hash) REFERENCES public.script(workspace_id, hash) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dbt_graph_snapshot dbt_graph_snapshot_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dbt_graph_snapshot
    ADD CONSTRAINT dbt_graph_snapshot_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dbt_node dbt_node_script_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dbt_node
    ADD CONSTRAINT dbt_node_script_fkey FOREIGN KEY (workspace_id, script_hash) REFERENCES public.script(workspace_id, hash) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dbt_node dbt_node_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dbt_node
    ADD CONSTRAINT dbt_node_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dbt_run_progress dbt_run_progress_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dbt_run_progress
    ADD CONSTRAINT dbt_run_progress_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dbt_run_state dbt_run_state_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dbt_run_state
    ADD CONSTRAINT dbt_run_state_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: deployment_metadata deployment_metadata_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deployment_metadata
    ADD CONSTRAINT deployment_metadata_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: dispatch_event dispatch_event_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispatch_event
    ADD CONSTRAINT dispatch_event_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: draft draft_password_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.draft
    ADD CONSTRAINT draft_password_fkey FOREIGN KEY (email) REFERENCES public.password(email) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: draft draft_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.draft
    ADD CONSTRAINT draft_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: usr_to_group fk_group; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usr_to_group
    ADD CONSTRAINT fk_group FOREIGN KEY (workspace_id, group_) REFERENCES public.group_(workspace_id, name);


--
-- Name: native_trigger fk_native_trigger_workspace; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.native_trigger
    ADD CONSTRAINT fk_native_trigger_workspace FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: postgres_trigger fk_postgres_trigger_workspace; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postgres_trigger
    ADD CONSTRAINT fk_postgres_trigger_workspace FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: sqs_trigger fk_sqs_trigger_workspace; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sqs_trigger
    ADD CONSTRAINT fk_sqs_trigger_workspace FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: workspace_integrations fk_workspace_integrations_workspace; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_integrations
    ADD CONSTRAINT fk_workspace_integrations_workspace FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: workspace_runnable_dependencies fk_workspace_runnable_dependencies_app_path; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_runnable_dependencies
    ADD CONSTRAINT fk_workspace_runnable_dependencies_app_path FOREIGN KEY (app_path, workspace_id) REFERENCES public.app(path, workspace_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: flow_conversation_message flow_conversation_message_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_conversation_message
    ADD CONSTRAINT flow_conversation_message_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.flow_conversation(id) ON DELETE CASCADE;


--
-- Name: flow_conversation flow_conversation_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_conversation
    ADD CONSTRAINT flow_conversation_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: flow_node flow_node_path_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_node
    ADD CONSTRAINT flow_node_path_workspace_id_fkey FOREIGN KEY (path, workspace_id) REFERENCES public.flow(path, workspace_id) ON DELETE CASCADE;


--
-- Name: flow_node flow_node_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_node
    ADD CONSTRAINT flow_node_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: flow_version_lite flow_version_lite_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_version_lite
    ADD CONSTRAINT flow_version_lite_id_fkey FOREIGN KEY (id) REFERENCES public.flow_version(id) ON DELETE CASCADE;


--
-- Name: flow_version flow_version_workspace_id_path_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_version
    ADD CONSTRAINT flow_version_workspace_id_path_fkey FOREIGN KEY (workspace_id, path) REFERENCES public.flow(workspace_id, path) ON DELETE CASCADE;


--
-- Name: flow flow_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow
    ADD CONSTRAINT flow_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: workspace_runnable_dependencies flow_workspace_runnables_workspace_id_flow_path_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_runnable_dependencies
    ADD CONSTRAINT flow_workspace_runnables_workspace_id_flow_path_fkey FOREIGN KEY (flow_path, workspace_id) REFERENCES public.flow(path, workspace_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: folder_permission_history folder_permission_history_workspace_id_folder_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folder_permission_history
    ADD CONSTRAINT folder_permission_history_workspace_id_folder_name_fkey FOREIGN KEY (workspace_id, folder_name) REFERENCES public.folder(workspace_id, name) ON DELETE CASCADE;


--
-- Name: folder folder_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT folder_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: group_ group__workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_
    ADD CONSTRAINT group__workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: group_permission_history group_permission_history_workspace_id_group_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_permission_history
    ADD CONSTRAINT group_permission_history_workspace_id_group_name_fkey FOREIGN KEY (workspace_id, group_name) REFERENCES public.group_(workspace_id, name) ON DELETE CASCADE;


--
-- Name: input input_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.input
    ADD CONSTRAINT input_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: job_stats job_stats_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_stats
    ADD CONSTRAINT job_stats_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: join_pending_inputs join_pending_inputs_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.join_pending_inputs
    ADD CONSTRAINT join_pending_inputs_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: kafka_pending_commits kafka_pending_commits_workspace_id_kafka_trigger_path_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kafka_pending_commits
    ADD CONSTRAINT kafka_pending_commits_workspace_id_kafka_trigger_path_fkey FOREIGN KEY (workspace_id, kafka_trigger_path) REFERENCES public.kafka_trigger(workspace_id, path) ON DELETE CASCADE;


--
-- Name: lock_hash lock_hash_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lock_hash
    ADD CONSTRAINT lock_hash_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: macro_definition macro_definition_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.macro_definition
    ADD CONSTRAINT macro_definition_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: macro_usage macro_usage_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.macro_usage
    ADD CONSTRAINT macro_usage_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: materialized_asset_schema materialized_asset_schema_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materialized_asset_schema
    ADD CONSTRAINT materialized_asset_schema_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: materialized_partition materialized_partition_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materialized_partition
    ADD CONSTRAINT materialized_partition_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mcp_oauth_refresh_token mcp_oauth_refresh_token_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcp_oauth_refresh_token
    ADD CONSTRAINT mcp_oauth_refresh_token_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.mcp_oauth_server_client(client_id) ON DELETE CASCADE;


--
-- Name: mcp_oauth_server_code mcp_oauth_server_code_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcp_oauth_server_code
    ADD CONSTRAINT mcp_oauth_server_code_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.mcp_oauth_server_client(client_id) ON DELETE CASCADE;


--
-- Name: nats_trigger nats_trigger_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nats_trigger
    ADD CONSTRAINT nats_trigger_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: pipeline_freshness_state pipeline_freshness_state_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pipeline_freshness_state
    ADD CONSTRAINT pipeline_freshness_state_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: raw_app raw_app_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raw_app
    ADD CONSTRAINT raw_app_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: raw_script_temp raw_script_temp_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raw_script_temp
    ADD CONSTRAINT raw_script_temp_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: resource_type resource_type_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_type
    ADD CONSTRAINT resource_type_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: resource_version resource_version_workspace_id_path_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_version
    ADD CONSTRAINT resource_version_workspace_id_path_fkey FOREIGN KEY (workspace_id, path) REFERENCES public.resource(workspace_id, path) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: resource resource_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: resume_job resume_job_flow_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resume_job
    ADD CONSTRAINT resume_job_flow_fkey FOREIGN KEY (flow) REFERENCES public.v2_job_queue(id) ON DELETE CASCADE;


--
-- Name: schedule schedule_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedule
    ADD CONSTRAINT schedule_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: script_trigger script_trigger_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.script_trigger
    ADD CONSTRAINT script_trigger_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: script script_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.script
    ADD CONSTRAINT script_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: token token_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: trashbin trashbin_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trashbin
    ADD CONSTRAINT trashbin_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: trigger_history trigger_history_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trigger_history
    ADD CONSTRAINT trigger_history_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: usr_to_group usr_to_group_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usr_to_group
    ADD CONSTRAINT usr_to_group_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: usr usr_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usr
    ADD CONSTRAINT usr_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: v2_job_runtime v2_job_runtime_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2_job_runtime
    ADD CONSTRAINT v2_job_runtime_id_fkey FOREIGN KEY (id) REFERENCES public.v2_job_queue(id) ON DELETE CASCADE;


--
-- Name: v2_job_status v2_job_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.v2_job_status
    ADD CONSTRAINT v2_job_status_id_fkey FOREIGN KEY (id) REFERENCES public.v2_job_queue(id) ON DELETE CASCADE;


--
-- Name: variable variable_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variable
    ADD CONSTRAINT variable_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: volume volume_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volume
    ADD CONSTRAINT volume_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: worker_group_job_stats worker_group_job_stats_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_group_job_stats
    ADD CONSTRAINT worker_group_job_stats_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: workspace_fork_deployment_request_assignee workspace_fork_deployment_request_assignee_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_fork_deployment_request_assignee
    ADD CONSTRAINT workspace_fork_deployment_request_assignee_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.workspace_fork_deployment_request(id) ON DELETE CASCADE;


--
-- Name: workspace_fork_deployment_request_comment workspace_fork_deployment_request_comment_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_fork_deployment_request_comment
    ADD CONSTRAINT workspace_fork_deployment_request_comment_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.workspace_fork_deployment_request_comment(id) ON DELETE CASCADE;


--
-- Name: workspace_fork_deployment_request_comment workspace_fork_deployment_request_comment_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_fork_deployment_request_comment
    ADD CONSTRAINT workspace_fork_deployment_request_comment_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.workspace_fork_deployment_request(id) ON DELETE CASCADE;


--
-- Name: workspace_fork_deployment_request workspace_fork_deployment_request_fork_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_fork_deployment_request
    ADD CONSTRAINT workspace_fork_deployment_request_fork_workspace_id_fkey FOREIGN KEY (fork_workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: workspace_fork_deployment_request workspace_fork_deployment_request_source_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_fork_deployment_request
    ADD CONSTRAINT workspace_fork_deployment_request_source_workspace_id_fkey FOREIGN KEY (source_workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: workspace_invite workspace_invite_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invite
    ADD CONSTRAINT workspace_invite_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: workspace_key workspace_key_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_key
    ADD CONSTRAINT workspace_key_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: workspace_multipart_inflight workspace_multipart_inflight_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_multipart_inflight
    ADD CONSTRAINT workspace_multipart_inflight_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: workspace workspace_parent_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace
    ADD CONSTRAINT workspace_parent_workspace_id_fkey FOREIGN KEY (parent_workspace_id) REFERENCES public.workspace(id) ON DELETE SET NULL;


--
-- Name: workspace_protection_rule workspace_protection_rule_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_protection_rule
    ADD CONSTRAINT workspace_protection_rule_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: workspace_settings workspace_settings_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_settings
    ADD CONSTRAINT workspace_settings_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id);


--
-- Name: workspace_shared_ui workspace_shared_ui_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_shared_ui
    ADD CONSTRAINT workspace_shared_ui_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: workspace_storage_usage workspace_storage_usage_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_storage_usage
    ADD CONSTRAINT workspace_storage_usage_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON DELETE CASCADE;


--
-- Name: ws_specific ws_specific_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ws_specific
    ADD CONSTRAINT ws_specific_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: folder_permission_history admin_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all ON public.folder_permission_history TO windmill_admin USING (true) WITH CHECK (true);


--
-- Name: group_permission_history admin_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all ON public.group_permission_history TO windmill_admin USING (true) WITH CHECK (true);


--
-- Name: trigger_history admin_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all ON public.trigger_history TO windmill_admin USING (true) WITH CHECK (true);


--
-- Name: account admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.account TO windmill_admin USING (true);


--
-- Name: amqp_trigger admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.amqp_trigger TO windmill_admin USING (true);


--
-- Name: app admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.app TO windmill_admin USING (true);


--
-- Name: audit admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.audit TO windmill_admin USING (true);


--
-- Name: audit_partitioned admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.audit_partitioned TO windmill_admin USING (true);


--
-- Name: azure_trigger admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.azure_trigger TO windmill_admin USING (true);


--
-- Name: capture admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.capture TO windmill_admin USING (true);


--
-- Name: capture_config admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.capture_config TO windmill_admin USING (true);


--
-- Name: email_trigger admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.email_trigger TO windmill_admin USING (true);


--
-- Name: flow admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.flow TO windmill_admin USING (true);


--
-- Name: flow_conversation admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.flow_conversation TO windmill_admin USING (true);


--
-- Name: flow_conversation_message admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.flow_conversation_message TO windmill_admin USING (true);


--
-- Name: folder admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.folder TO windmill_admin USING (true);


--
-- Name: gcp_trigger admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.gcp_trigger TO windmill_admin USING (true);


--
-- Name: http_trigger admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.http_trigger TO windmill_admin USING (true);


--
-- Name: kafka_trigger admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.kafka_trigger TO windmill_admin USING (true);


--
-- Name: mqtt_trigger admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.mqtt_trigger TO windmill_admin USING (true);


--
-- Name: nats_trigger admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.nats_trigger TO windmill_admin USING (true);


--
-- Name: postgres_trigger admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.postgres_trigger TO windmill_admin USING (true);


--
-- Name: raw_app admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.raw_app TO windmill_admin USING (true);


--
-- Name: resource admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.resource TO windmill_admin USING (true);


--
-- Name: resource_version admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.resource_version TO windmill_admin USING (true);


--
-- Name: schedule admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.schedule TO windmill_admin USING (true);


--
-- Name: script admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.script TO windmill_admin USING (true);


--
-- Name: sqs_trigger admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.sqs_trigger TO windmill_admin USING (true);


--
-- Name: usr_to_group admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.usr_to_group TO windmill_admin USING (true);


--
-- Name: v2_job admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.v2_job TO windmill_admin USING (true);


--
-- Name: v2_job_completed admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.v2_job_completed TO windmill_admin USING (true);


--
-- Name: v2_job_queue admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.v2_job_queue TO windmill_admin USING (true);


--
-- Name: v2_job_runtime admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.v2_job_runtime TO windmill_admin;


--
-- Name: v2_job_status admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.v2_job_status TO windmill_admin;


--
-- Name: variable admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.variable TO windmill_admin USING (true);


--
-- Name: websocket_trigger admin_policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_policy ON public.websocket_trigger TO windmill_admin USING (true);


--
-- Name: folder_permission_history allow_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_insert ON public.folder_permission_history FOR INSERT TO windmill_user WITH CHECK (true);


--
-- Name: group_permission_history allow_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_insert ON public.group_permission_history FOR INSERT TO windmill_user WITH CHECK (true);


--
-- Name: trigger_history allow_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_insert ON public.trigger_history FOR INSERT TO windmill_user WITH CHECK (true);


--
-- Name: amqp_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.amqp_trigger ENABLE ROW LEVEL SECURITY;

--
-- Name: app; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.app ENABLE ROW LEVEL SECURITY;

--
-- Name: audit; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.audit ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_partitioned; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.audit_partitioned ENABLE ROW LEVEL SECURITY;

--
-- Name: azure_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.azure_trigger ENABLE ROW LEVEL SECURITY;

--
-- Name: capture; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.capture ENABLE ROW LEVEL SECURITY;

--
-- Name: capture_config; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.capture_config ENABLE ROW LEVEL SECURITY;

--
-- Name: email_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.email_trigger ENABLE ROW LEVEL SECURITY;

--
-- Name: flow; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.flow ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_conversation; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.flow_conversation ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_conversation_message; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.flow_conversation_message ENABLE ROW LEVEL SECURITY;

--
-- Name: folder; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.folder ENABLE ROW LEVEL SECURITY;

--
-- Name: folder_permission_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.folder_permission_history ENABLE ROW LEVEL SECURITY;

--
-- Name: gcp_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.gcp_trigger ENABLE ROW LEVEL SECURITY;

--
-- Name: group_permission_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.group_permission_history ENABLE ROW LEVEL SECURITY;

--
-- Name: http_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.http_trigger ENABLE ROW LEVEL SECURITY;

--
-- Name: kafka_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.kafka_trigger ENABLE ROW LEVEL SECURITY;

--
-- Name: mqtt_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.mqtt_trigger ENABLE ROW LEVEL SECURITY;

--
-- Name: nats_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.nats_trigger ENABLE ROW LEVEL SECURITY;

--
-- Name: postgres_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.postgres_trigger ENABLE ROW LEVEL SECURITY;

--
-- Name: raw_app; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.raw_app ENABLE ROW LEVEL SECURITY;

--
-- Name: resource; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.resource ENABLE ROW LEVEL SECURITY;

--
-- Name: resource_version; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.resource_version ENABLE ROW LEVEL SECURITY;

--
-- Name: audit schedule; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY schedule ON public.audit FOR INSERT TO windmill_user WITH CHECK (((username)::text ~~ 'schedule-%'::text));


--
-- Name: audit_partitioned schedule; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY schedule ON public.audit_partitioned FOR INSERT TO windmill_user WITH CHECK (((username)::text ~~ 'schedule-%'::text));


--
-- Name: schedule; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.schedule ENABLE ROW LEVEL SECURITY;

--
-- Name: audit schedule_audit; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY schedule_audit ON public.audit FOR INSERT TO windmill_user WITH CHECK (((parameters ->> 'end_user'::text) ~~ 'schedule-%'::text));


--
-- Name: audit_partitioned schedule_audit; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY schedule_audit ON public.audit_partitioned FOR INSERT TO windmill_user WITH CHECK (((parameters ->> 'end_user'::text) ~~ 'schedule-%'::text));


--
-- Name: script; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.script ENABLE ROW LEVEL SECURITY;

--
-- Name: folder_permission_history see_extra_perms_groups; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups ON public.folder_permission_history FOR SELECT TO windmill_user USING ((EXISTS ( SELECT 1
   FROM public.folder f
  WHERE (((f.workspace_id)::text = (folder_permission_history.workspace_id)::text) AND ((f.name)::text = (folder_permission_history.folder_name)::text) AND (f.extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array))))));


--
-- Name: group_permission_history see_extra_perms_groups; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups ON public.group_permission_history FOR SELECT TO windmill_user USING ((EXISTS ( SELECT 1
   FROM public.group_ g,
    LATERAL jsonb_each_text(g.extra_perms) f(key, value)
  WHERE (((g.workspace_id)::text = (group_permission_history.workspace_id)::text) AND ((g.name)::text = (group_permission_history.group_name)::text) AND (split_part(f.key, '/'::text, 1) = 'g'::text) AND (f.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (f.value)::boolean))));


--
-- Name: usr_to_group see_extra_perms_groups; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups ON public.usr_to_group TO windmill_user USING (true) WITH CHECK ((EXISTS ( SELECT f.key,
    f.value
   FROM public.group_ g,
    LATERAL jsonb_each_text(g.extra_perms) f(key, value)
  WHERE (((usr_to_group.group_)::text = (g.name)::text) AND ((usr_to_group.workspace_id)::text = (g.workspace_id)::text) AND (split_part(f.key, '/'::text, 1) = 'g'::text) AND (f.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (f.value)::boolean))));


--
-- Name: amqp_trigger see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.amqp_trigger FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(amqp_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: app see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.app FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(app.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: azure_trigger see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.azure_trigger FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(azure_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: email_trigger see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.email_trigger FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(email_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: flow see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.flow FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(flow.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: folder see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.folder FOR DELETE TO windmill_user USING ((EXISTS ( SELECT o.o
   FROM unnest(folder.owners) o(o)
  WHERE ((o.o)::text = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])))));


--
-- Name: gcp_trigger see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.gcp_trigger FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(gcp_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: http_trigger see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.http_trigger FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(http_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: kafka_trigger see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.kafka_trigger FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(kafka_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: mqtt_trigger see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.mqtt_trigger FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(mqtt_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: nats_trigger see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.nats_trigger FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(nats_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: postgres_trigger see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.postgres_trigger FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(postgres_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: raw_app see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.raw_app FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(raw_app.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: resource see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.resource FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(resource.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: schedule see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.schedule FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(schedule.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: script see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.script FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(script.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: sqs_trigger see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.sqs_trigger FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(sqs_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: variable see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.variable FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(variable.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: websocket_trigger see_extra_perms_groups_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_delete ON public.websocket_trigger FOR DELETE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(websocket_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: amqp_trigger see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.amqp_trigger FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(amqp_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: app see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.app FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(app.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: azure_trigger see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.azure_trigger FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(azure_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: email_trigger see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.email_trigger FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(email_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: flow see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.flow FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(flow.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: folder see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.folder FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT o.o
   FROM unnest(folder.owners) o(o)
  WHERE ((o.o)::text = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])))));


--
-- Name: gcp_trigger see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.gcp_trigger FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(gcp_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: http_trigger see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.http_trigger FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(http_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: kafka_trigger see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.kafka_trigger FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(kafka_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: mqtt_trigger see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.mqtt_trigger FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(mqtt_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: nats_trigger see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.nats_trigger FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(nats_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: postgres_trigger see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.postgres_trigger FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(postgres_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: raw_app see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.raw_app FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(raw_app.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: resource see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.resource FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(resource.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: schedule see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.schedule FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(schedule.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: script see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.script FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(script.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: sqs_trigger see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.sqs_trigger FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(sqs_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: variable see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.variable FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(variable.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: websocket_trigger see_extra_perms_groups_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_insert ON public.websocket_trigger FOR INSERT TO windmill_user WITH CHECK ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(websocket_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: amqp_trigger see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.amqp_trigger FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: app see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.app FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: azure_trigger see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.azure_trigger FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: email_trigger see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.email_trigger FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: flow see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.flow FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: folder see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.folder FOR SELECT TO windmill_user USING (((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)) OR (EXISTS ( SELECT o.o
   FROM unnest(folder.owners) o(o)
  WHERE ((o.o)::text = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[]))))));


--
-- Name: gcp_trigger see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.gcp_trigger FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: http_trigger see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.http_trigger FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: kafka_trigger see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.kafka_trigger FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: mqtt_trigger see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.mqtt_trigger FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: nats_trigger see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.nats_trigger FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: postgres_trigger see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.postgres_trigger FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: raw_app see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.raw_app FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: resource see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.resource FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: schedule see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.schedule FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: script see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.script FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: sqs_trigger see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.sqs_trigger FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: variable see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.variable FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: websocket_trigger see_extra_perms_groups_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_select ON public.websocket_trigger FOR SELECT TO windmill_user USING ((extra_perms ?| ( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)));


--
-- Name: amqp_trigger see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.amqp_trigger FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(amqp_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: app see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.app FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(app.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: azure_trigger see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.azure_trigger FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(azure_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: email_trigger see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.email_trigger FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(email_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: flow see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.flow FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(flow.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: folder see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.folder FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT o.o
   FROM unnest(folder.owners) o(o)
  WHERE ((o.o)::text = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])))));


--
-- Name: gcp_trigger see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.gcp_trigger FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(gcp_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: http_trigger see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.http_trigger FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(http_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: kafka_trigger see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.kafka_trigger FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(kafka_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: mqtt_trigger see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.mqtt_trigger FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(mqtt_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: nats_trigger see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.nats_trigger FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(nats_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: postgres_trigger see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.postgres_trigger FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(postgres_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: raw_app see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.raw_app FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(raw_app.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: resource see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.resource FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(resource.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: schedule see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.schedule FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(schedule.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: script see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.script FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(script.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: sqs_trigger see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.sqs_trigger FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(sqs_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: variable see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.variable FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(variable.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: websocket_trigger see_extra_perms_groups_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_groups_update ON public.websocket_trigger FOR UPDATE TO windmill_user USING ((EXISTS ( SELECT jsonb_each_text.key,
    jsonb_each_text.value
   FROM jsonb_each_text(websocket_trigger.extra_perms) jsonb_each_text(key, value)
  WHERE ((split_part(jsonb_each_text.key, '/'::text, 1) = 'g'::text) AND (jsonb_each_text.key = ANY (( SELECT regexp_split_to_array(current_setting('session.pgroups'::text), ','::text) AS regexp_split_to_array)::text[])) AND (jsonb_each_text.value)::boolean))));


--
-- Name: folder_permission_history see_extra_perms_user; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user ON public.folder_permission_history FOR SELECT TO windmill_user USING ((EXISTS ( SELECT 1
   FROM public.folder f
  WHERE (((f.workspace_id)::text = (folder_permission_history.workspace_id)::text) AND ((f.name)::text = (folder_permission_history.folder_name)::text) AND (f.extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat))))));


--
-- Name: group_permission_history see_extra_perms_user; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user ON public.group_permission_history FOR SELECT TO windmill_user USING ((EXISTS ( SELECT 1
   FROM public.group_ g
  WHERE (((g.workspace_id)::text = (group_permission_history.workspace_id)::text) AND ((g.name)::text = (group_permission_history.group_name)::text) AND ((g.extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean))));


--
-- Name: usr_to_group see_extra_perms_user; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user ON public.usr_to_group TO windmill_user USING (true) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.group_
  WHERE (((usr_to_group.group_)::text = (group_.name)::text) AND ((usr_to_group.workspace_id)::text = (group_.workspace_id)::text) AND ((group_.extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean))));


--
-- Name: amqp_trigger see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.amqp_trigger FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: app see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.app FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: azure_trigger see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.azure_trigger FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: email_trigger see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.email_trigger FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: flow see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.flow FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: folder see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.folder FOR DELETE TO windmill_user USING ((( SELECT concat('u/', current_setting('session.user'::text)) AS concat) = ANY ((owners)::text[])));


--
-- Name: gcp_trigger see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.gcp_trigger FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: http_trigger see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.http_trigger FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: kafka_trigger see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.kafka_trigger FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: mqtt_trigger see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.mqtt_trigger FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: nats_trigger see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.nats_trigger FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: postgres_trigger see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.postgres_trigger FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: raw_app see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.raw_app FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: resource see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.resource FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: schedule see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.schedule FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: script see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.script FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: sqs_trigger see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.sqs_trigger FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: variable see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.variable FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: websocket_trigger see_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_delete ON public.websocket_trigger FOR DELETE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: amqp_trigger see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.amqp_trigger FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: app see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.app FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: azure_trigger see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.azure_trigger FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: email_trigger see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.email_trigger FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: flow see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.flow FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: folder see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.folder FOR INSERT TO windmill_user WITH CHECK ((( SELECT concat('u/', current_setting('session.user'::text)) AS concat) = ANY ((owners)::text[])));


--
-- Name: gcp_trigger see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.gcp_trigger FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: http_trigger see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.http_trigger FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: kafka_trigger see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.kafka_trigger FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: mqtt_trigger see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.mqtt_trigger FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: nats_trigger see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.nats_trigger FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: postgres_trigger see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.postgres_trigger FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: raw_app see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.raw_app FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: resource see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.resource FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: schedule see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.schedule FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: script see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.script FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: sqs_trigger see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.sqs_trigger FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: variable see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.variable FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: websocket_trigger see_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_insert ON public.websocket_trigger FOR INSERT TO windmill_user WITH CHECK (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: amqp_trigger see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.amqp_trigger FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: app see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.app FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: azure_trigger see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.azure_trigger FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: email_trigger see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.email_trigger FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: flow see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.flow FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: folder see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.folder FOR SELECT TO windmill_user USING (((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)) OR (( SELECT concat('u/', current_setting('session.user'::text)) AS concat) = ANY ((owners)::text[]))));


--
-- Name: gcp_trigger see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.gcp_trigger FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: http_trigger see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.http_trigger FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: kafka_trigger see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.kafka_trigger FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: mqtt_trigger see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.mqtt_trigger FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: nats_trigger see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.nats_trigger FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: postgres_trigger see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.postgres_trigger FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: raw_app see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.raw_app FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: resource see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.resource FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: schedule see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.schedule FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: script see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.script FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: sqs_trigger see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.sqs_trigger FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: variable see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.variable FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: websocket_trigger see_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_select ON public.websocket_trigger FOR SELECT TO windmill_user USING ((extra_perms ? ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)));


--
-- Name: amqp_trigger see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.amqp_trigger FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: app see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.app FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: azure_trigger see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.azure_trigger FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: email_trigger see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.email_trigger FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: flow see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.flow FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: folder see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.folder FOR UPDATE TO windmill_user USING ((( SELECT concat('u/', current_setting('session.user'::text)) AS concat) = ANY ((owners)::text[])));


--
-- Name: gcp_trigger see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.gcp_trigger FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: http_trigger see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.http_trigger FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: kafka_trigger see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.kafka_trigger FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: mqtt_trigger see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.mqtt_trigger FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: nats_trigger see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.nats_trigger FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: postgres_trigger see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.postgres_trigger FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: raw_app see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.raw_app FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: resource see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.resource FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: schedule see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.schedule FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: script see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.script FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: sqs_trigger see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.sqs_trigger FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: variable see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.variable FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: websocket_trigger see_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_extra_perms_user_update ON public.websocket_trigger FOR UPDATE TO windmill_user USING (((extra_perms ->> ( SELECT concat('u/', current_setting('session.user'::text)) AS concat)))::boolean);


--
-- Name: trigger_history see_folder_extra_perms_user; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user ON public.trigger_history FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (regexp_split_to_array(current_setting('session.folders_read'::text), ','::text)))));


--
-- Name: v2_job see_folder_extra_perms_user; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user ON public.v2_job TO windmill_user USING (((visible_to_owner IS TRUE) AND (split_part((runnable_path)::text, '/'::text, 1) = 'f'::text) AND (split_part((runnable_path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: amqp_trigger see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.amqp_trigger FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: app see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.app FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: azure_trigger see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.azure_trigger FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: capture see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.capture FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: capture_config see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.capture_config FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: email_trigger see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.email_trigger FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: flow see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.flow FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: gcp_trigger see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.gcp_trigger FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: http_trigger see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.http_trigger FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: kafka_trigger see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.kafka_trigger FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: mqtt_trigger see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.mqtt_trigger FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: nats_trigger see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.nats_trigger FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: postgres_trigger see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.postgres_trigger FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: raw_app see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.raw_app FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: resource see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.resource FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: schedule see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.schedule FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: script see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.script FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: sqs_trigger see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.sqs_trigger FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: variable see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.variable FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: websocket_trigger see_folder_extra_perms_user_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_delete ON public.websocket_trigger FOR DELETE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: amqp_trigger see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.amqp_trigger FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: app see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.app FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: azure_trigger see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.azure_trigger FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: capture see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.capture FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: capture_config see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.capture_config FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: email_trigger see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.email_trigger FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: flow see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.flow FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: gcp_trigger see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.gcp_trigger FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: http_trigger see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.http_trigger FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: kafka_trigger see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.kafka_trigger FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: mqtt_trigger see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.mqtt_trigger FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: nats_trigger see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.nats_trigger FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: postgres_trigger see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.postgres_trigger FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: raw_app see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.raw_app FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: resource see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.resource FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: schedule see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.schedule FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: script see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.script FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: sqs_trigger see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.sqs_trigger FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: variable see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.variable FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: websocket_trigger see_folder_extra_perms_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_insert ON public.websocket_trigger FOR INSERT TO windmill_user WITH CHECK (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: amqp_trigger see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.amqp_trigger FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: app see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.app FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: azure_trigger see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.azure_trigger FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: capture see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.capture FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: capture_config see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.capture_config FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: email_trigger see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.email_trigger FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: flow see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.flow FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: gcp_trigger see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.gcp_trigger FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: http_trigger see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.http_trigger FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: kafka_trigger see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.kafka_trigger FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: mqtt_trigger see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.mqtt_trigger FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: nats_trigger see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.nats_trigger FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: postgres_trigger see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.postgres_trigger FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: raw_app see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.raw_app FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: resource see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.resource FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: schedule see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.schedule FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: script see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.script FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: sqs_trigger see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.sqs_trigger FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: variable see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.variable FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: websocket_trigger see_folder_extra_perms_user_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_select ON public.websocket_trigger FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_read'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: amqp_trigger see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.amqp_trigger FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: app see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.app FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: azure_trigger see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.azure_trigger FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: capture see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.capture FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: capture_config see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.capture_config FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: email_trigger see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.email_trigger FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: flow see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.flow FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: gcp_trigger see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.gcp_trigger FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: http_trigger see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.http_trigger FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: kafka_trigger see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.kafka_trigger FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: mqtt_trigger see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.mqtt_trigger FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: nats_trigger see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.nats_trigger FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: postgres_trigger see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.postgres_trigger FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: raw_app see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.raw_app FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: resource see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.resource FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: schedule see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.schedule FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: script see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.script FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: sqs_trigger see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.sqs_trigger FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: variable see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.variable FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: websocket_trigger see_folder_extra_perms_user_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_folder_extra_perms_user_update ON public.websocket_trigger FOR UPDATE TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'f'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.folders_write'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: capture see_from_allowed_runnables; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_from_allowed_runnables ON public.capture TO windmill_user USING (((is_flow AND (EXISTS ( SELECT 1
   FROM public.flow
  WHERE (((flow.workspace_id)::text = (capture.workspace_id)::text) AND ((flow.path)::text = (capture.path)::text))))) OR ((NOT is_flow) AND (EXISTS ( SELECT 1
   FROM public.script
  WHERE (((script.workspace_id)::text = (capture.workspace_id)::text) AND ((script.path)::text = (capture.path)::text)))))));


--
-- Name: capture_config see_from_allowed_runnables; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_from_allowed_runnables ON public.capture_config TO windmill_user USING (((is_flow AND (EXISTS ( SELECT 1
   FROM public.flow
  WHERE (((flow.workspace_id)::text = (capture_config.workspace_id)::text) AND ((flow.path)::text = (capture_config.path)::text))))) OR ((NOT is_flow) AND (EXISTS ( SELECT 1
   FROM public.script
  WHERE (((script.workspace_id)::text = (capture_config.workspace_id)::text) AND ((script.path)::text = (capture_config.path)::text)))))));


--
-- Name: amqp_trigger see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.amqp_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: app see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.app TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: azure_trigger see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.azure_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: capture see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.capture TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: capture_config see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.capture_config TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: email_trigger see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.email_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: flow see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.flow TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: gcp_trigger see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.gcp_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: http_trigger see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.http_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: kafka_trigger see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.kafka_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: mqtt_trigger see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.mqtt_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: nats_trigger see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.nats_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: postgres_trigger see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.postgres_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: raw_app see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.raw_app TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: resource see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.resource TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: schedule see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.schedule TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: script see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.script TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: sqs_trigger see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.sqs_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: trigger_history see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.trigger_history FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (regexp_split_to_array(current_setting('session.groups'::text), ','::text)))));


--
-- Name: v2_job see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.v2_job TO windmill_user USING (((split_part((permissioned_as)::text, '/'::text, 1) = 'g'::text) AND (split_part((permissioned_as)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: variable see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.variable TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: websocket_trigger see_member; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member ON public.websocket_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'g'::text) AND (split_part((path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: v2_job see_member_path; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_member_path ON public.v2_job TO windmill_user USING (((visible_to_owner IS TRUE) AND (split_part((runnable_path)::text, '/'::text, 1) = 'g'::text) AND (split_part((runnable_path)::text, '/'::text, 2) = ANY (( SELECT regexp_split_to_array(current_setting('session.groups'::text), ','::text) AS regexp_split_to_array)::text[]))));


--
-- Name: amqp_trigger see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.amqp_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: app see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.app TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: audit see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.audit TO windmill_user USING (((username)::text = ( SELECT current_setting('session.user'::text) AS current_setting)));


--
-- Name: audit_partitioned see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.audit_partitioned TO windmill_user USING (((username)::text = ( SELECT current_setting('session.user'::text) AS current_setting)));


--
-- Name: azure_trigger see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.azure_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: capture see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.capture TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: capture_config see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.capture_config TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: email_trigger see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.email_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: flow see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.flow TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: flow_conversation see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.flow_conversation TO windmill_user USING (((created_by)::text = ( SELECT current_setting('session.user'::text) AS current_setting)));


--
-- Name: flow_conversation_message see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.flow_conversation_message TO windmill_user USING ((EXISTS ( SELECT 1
   FROM public.flow_conversation
  WHERE ((flow_conversation.id = flow_conversation_message.conversation_id) AND ((flow_conversation.created_by)::text = ( SELECT current_setting('session.user'::text) AS current_setting))))));


--
-- Name: gcp_trigger see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.gcp_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: http_trigger see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.http_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: kafka_trigger see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.kafka_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: mqtt_trigger see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.mqtt_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: nats_trigger see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.nats_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: postgres_trigger see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.postgres_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: raw_app see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.raw_app TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: resource see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.resource TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: schedule see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.schedule TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: script see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.script TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: sqs_trigger see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.sqs_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: trigger_history see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.trigger_history FOR SELECT TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = current_setting('session.user'::text))));


--
-- Name: v2_job see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.v2_job TO windmill_user USING (((split_part((permissioned_as)::text, '/'::text, 1) = 'u'::text) AND (split_part((permissioned_as)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: variable see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.variable TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: websocket_trigger see_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own ON public.websocket_trigger TO windmill_user USING (((split_part((path)::text, '/'::text, 1) = 'u'::text) AND (split_part((path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: v2_job see_own_path; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_own_path ON public.v2_job TO windmill_user USING (((visible_to_owner IS TRUE) AND (split_part((runnable_path)::text, '/'::text, 1) = 'u'::text) AND (split_part((runnable_path)::text, '/'::text, 2) = ( SELECT current_setting('session.user'::text) AS current_setting))));


--
-- Name: resource_version see_parent_resource; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY see_parent_resource ON public.resource_version FOR SELECT TO windmill_user USING ((EXISTS ( SELECT 1
   FROM public.resource r
  WHERE (((r.workspace_id)::text = (resource_version.workspace_id)::text) AND ((r.path)::text = (resource_version.path)::text)))));


--
-- Name: sqs_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sqs_trigger ENABLE ROW LEVEL SECURITY;

--
-- Name: trigger_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.trigger_history ENABLE ROW LEVEL SECURITY;

--
-- Name: usr_to_group; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.usr_to_group ENABLE ROW LEVEL SECURITY;

--
-- Name: v2_job; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.v2_job ENABLE ROW LEVEL SECURITY;

--
-- Name: variable; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.variable ENABLE ROW LEVEL SECURITY;

--
-- Name: audit webhook; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY webhook ON public.audit FOR INSERT TO windmill_user WITH CHECK (((username)::text ~~ 'webhook-%'::text));


--
-- Name: audit_partitioned webhook; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY webhook ON public.audit_partitioned FOR INSERT TO windmill_user WITH CHECK (((username)::text ~~ 'webhook-%'::text));


--
-- Name: websocket_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.websocket_trigger ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--


