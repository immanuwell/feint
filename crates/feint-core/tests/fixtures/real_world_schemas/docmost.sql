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
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: ai_chat_messages_tsvector_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ai_chat_messages_tsvector_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      NEW.tsv := to_tsvector('english', f_unaccent(substring(coalesce(NEW.content, ''), 1, 100000)));
      RETURN NEW;
    END;
    $$;


--
-- Name: base_cell_array(jsonb, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.base_cell_array(cells jsonb, prop text) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $$ SELECT cells->prop::text $$;


--
-- Name: base_cell_bool(jsonb, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.base_cell_bool(cells jsonb, prop text) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $$
      SELECT CASE jsonb_typeof(cells->prop::text)
        WHEN 'boolean' THEN (cells->>prop::text)::boolean
        WHEN 'string' THEN
          CASE
            WHEN lower(btrim(cells->>prop::text)) IN
              ('true','t','yes','y','on','1','false','f','no','n','off','0')
            THEN (cells->>prop::text)::boolean
          END
      END
    $$;


--
-- Name: base_cell_numeric(jsonb, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.base_cell_numeric(cells jsonb, prop text) RETURNS numeric
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
      SELECT CASE jsonb_typeof(cells->prop::text)
        WHEN 'number' THEN (cells->>prop::text)::numeric
        WHEN 'string' THEN
          CASE
            WHEN (cells->>prop::text) ~
              '^[[:space:]]*[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+)?[[:space:]]*$'
            THEN (cells->>prop::text)::numeric
          END
      END
    $_$;


--
-- Name: base_cell_text(jsonb, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.base_cell_text(cells jsonb, prop text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $$ SELECT cells->>prop::text $$;


--
-- Name: base_cell_timestamptz(jsonb, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.base_cell_timestamptz(cells jsonb, prop text) RETURNS timestamp with time zone
    LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE
    AS $$
      BEGIN RETURN (cells->>prop::text)::timestamptz;
      EXCEPTION WHEN others THEN RETURN NULL; END;
    $$;


--
-- Name: f_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
      SELECT unaccent('unaccent', $1);
    $_$;


--
-- Name: gen_uuid_v7(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gen_uuid_v7() RETURNS uuid
    LANGUAGE plpgsql
    AS $$
        declare
              v_time numeric := null;
      
              v_unix_t numeric := null;
              v_rand_a numeric := null;
              v_rand_b numeric := null;
      
              v_unix_t_hex varchar := null;
              v_rand_a_hex varchar := null;
              v_rand_b_hex varchar := null;
      
              v_output_bytes bytea := null;
              
              c_milli_factor numeric := 10^3::numeric;  -- 1000
              c_micro_factor numeric := 10^6::numeric;  -- 1000000
              c_scale_factor numeric := 4.096::numeric; -- 4.0 * (1024 / 1000)
              
              c_version bit(64) := x'0000000000007000'; -- RFC-4122 version: b'0111...'
              c_variant bit(64) := x'8000000000000000'; -- RFC-4122 variant: b'10xx...'

        begin
              v_time := extract(epoch from clock_timestamp());
              
              v_unix_t := trunc(v_time * c_milli_factor);
              v_rand_a := ((v_time * c_micro_factor) - (v_unix_t * c_milli_factor)) * c_scale_factor;
              v_rand_b := random()::numeric * 2^62::numeric;
              
              v_unix_t_hex := lpad(to_hex(v_unix_t::bigint), 12, '0');
              v_rand_a_hex := lpad(to_hex((v_rand_a::bigint::bit(64) | c_version)::bigint), 4, '0');
              v_rand_b_hex := lpad(to_hex((v_rand_b::bigint::bit(64) | c_variant)::bigint), 16, '0');
              
              v_output_bytes := decode(v_unix_t_hex || v_rand_a_hex || v_rand_b_hex, 'hex');
    
              return encode(v_output_bytes, 'hex')::uuid;
              
              v_output_bytes := decode(v_unix_t_hex || v_rand_a_hex || v_rand_b_hex, 'hex');
    
              return encode(v_output_bytes, 'hex')::uuid;
     end $$;


--
-- Name: jsonb_set_many(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_set_many(target jsonb, patches jsonb) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE
    AS $$
      DECLARE k text; v jsonb; result jsonb := coalesce(target, '{}'::jsonb);
      BEGIN
        IF patches IS NULL OR jsonb_typeof(patches) <> 'object' THEN
          RETURN result;
        END IF;
        FOR k, v IN SELECT * FROM jsonb_each(patches) LOOP
          IF v = 'null'::jsonb THEN
            result := result - k;
          ELSE
            result := jsonb_set(result, ARRAY[k], v, true);
          END IF;
        END LOOP;
        RETURN result;
      END;
    $$;


--
-- Name: pages_tsvector_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pages_tsvector_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    begin
        new.tsv :=
                  setweight(to_tsvector('english', f_unaccent(coalesce(new.title, ''))), 'A') ||
                  setweight(to_tsvector('english', f_unaccent(substring(coalesce(new.text_content, ''), 1, 1000000))), 'B');
        return new;
    end;
    $$;


--
-- Name: templates_tsvector_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.templates_tsvector_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    begin
        new.tsv :=
                  setweight(to_tsvector('english', f_unaccent(coalesce(new.title, ''))), 'A') ||
                  setweight(to_tsvector('english', f_unaccent(substring(coalesce(new.text_content, ''), 1, 1000000))), 'B');
        return new;
    end;
    $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_chat_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_chat_messages (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    chat_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    user_id uuid,
    role character varying NOT NULL,
    content text,
    tool_calls jsonb,
    metadata jsonb,
    tsv tsvector,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: ai_chats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_chats (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    workspace_id uuid NOT NULL,
    creator_id uuid NOT NULL,
    title character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_keys (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    name text,
    creator_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    expires_at timestamp with time zone,
    last_used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachments (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    file_name character varying NOT NULL,
    file_path character varying NOT NULL,
    file_size bigint,
    file_ext character varying NOT NULL,
    mime_type character varying,
    type character varying,
    creator_id uuid NOT NULL,
    page_id uuid,
    space_id uuid,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    text_content text,
    tsv tsvector,
    ai_chat_id uuid
);


--
-- Name: audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    workspace_id uuid NOT NULL,
    actor_id uuid,
    actor_type character varying DEFAULT 'user'::character varying NOT NULL,
    event character varying NOT NULL,
    resource_type character varying NOT NULL,
    resource_id uuid,
    space_id uuid,
    changes jsonb,
    metadata jsonb,
    ip_address inet,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: auth_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_accounts (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    user_id uuid NOT NULL,
    provider_user_id character varying NOT NULL,
    auth_provider_id uuid,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: auth_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_providers (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    name character varying NOT NULL,
    type text NOT NULL,
    saml_url character varying,
    saml_certificate character varying,
    oidc_issuer character varying,
    oidc_client_id character varying,
    oidc_client_secret character varying,
    allow_signup boolean DEFAULT false NOT NULL,
    is_enabled boolean DEFAULT false NOT NULL,
    creator_id uuid,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    group_sync boolean DEFAULT false NOT NULL,
    ldap_url character varying,
    ldap_bind_dn character varying,
    ldap_bind_password character varying,
    ldap_base_dn character varying,
    ldap_user_search_filter character varying,
    ldap_user_attributes jsonb DEFAULT '{}'::jsonb,
    ldap_tls_enabled boolean DEFAULT false,
    ldap_tls_ca_cert text,
    ldap_config jsonb DEFAULT '{}'::jsonb,
    settings jsonb DEFAULT '{}'::jsonb
);


--
-- Name: backlinks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.backlinks (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    source_page_id uuid NOT NULL,
    target_page_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: base_properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_properties (
    id character varying NOT NULL,
    page_id uuid NOT NULL,
    name character varying NOT NULL,
    type character varying NOT NULL,
    "position" character varying NOT NULL,
    type_options jsonb,
    pending_type character varying,
    pending_type_options jsonb,
    pending_token uuid,
    is_primary boolean DEFAULT false NOT NULL,
    schema_version integer DEFAULT 1 NOT NULL,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: base_rows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_rows (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    page_id uuid NOT NULL,
    cells jsonb DEFAULT '{}'::jsonb NOT NULL,
    "position" character varying NOT NULL,
    creator_id uuid,
    last_updated_by_id uuid,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: base_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_views (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    page_id uuid NOT NULL,
    name character varying NOT NULL,
    type character varying DEFAULT 'table'::character varying NOT NULL,
    "position" character varying NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    workspace_id uuid NOT NULL,
    creator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: billing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    stripe_subscription_id character varying NOT NULL,
    stripe_customer_id character varying,
    status character varying NOT NULL,
    quantity bigint,
    amount bigint,
    "interval" character varying,
    currency character varying,
    metadata jsonb,
    stripe_price_id character varying,
    stripe_item_id character varying,
    stripe_product_id character varying,
    period_start_at timestamp with time zone NOT NULL,
    period_end_at timestamp with time zone,
    cancel_at_period_end boolean,
    cancel_at timestamp with time zone,
    canceled_at timestamp with time zone,
    ended_at timestamp with time zone,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    billing_scheme character varying,
    tiered_up_to character varying,
    tiered_flat_amount bigint,
    tiered_unit_amount bigint,
    plan_name character varying
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    content jsonb,
    selection character varying,
    type character varying,
    creator_id uuid,
    page_id uuid NOT NULL,
    parent_comment_id uuid,
    workspace_id uuid NOT NULL,
    resolved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    edited_at timestamp with time zone,
    deleted_at timestamp with time zone,
    last_edited_by_id uuid,
    resolved_by_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    space_id uuid NOT NULL
);


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    user_id uuid NOT NULL,
    page_id uuid,
    space_id uuid,
    template_id uuid,
    type character varying NOT NULL,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: file_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_tasks (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    type character varying,
    source character varying,
    status character varying,
    file_name character varying NOT NULL,
    file_path character varying NOT NULL,
    file_size bigint,
    file_ext character varying,
    error_message character varying,
    creator_id uuid,
    space_id uuid,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    page_id uuid,
    metadata jsonb
);


--
-- Name: group_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_users (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    user_id uuid NOT NULL,
    group_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    name character varying NOT NULL,
    description text,
    is_default boolean NOT NULL,
    workspace_id uuid NOT NULL,
    creator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    scim_external_id text,
    is_external boolean DEFAULT false NOT NULL
);


--
-- Name: kysely_migration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kysely_migration (
    name character varying(255) NOT NULL,
    "timestamp" character varying(255) NOT NULL
);


--
-- Name: kysely_migration_lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kysely_migration_lock (
    id character varying(255) NOT NULL,
    is_locked integer DEFAULT 0 NOT NULL
);


--
-- Name: labels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.labels (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    name character varying NOT NULL,
    type character varying DEFAULT 'page'::character varying NOT NULL,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    user_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    type text NOT NULL,
    actor_id uuid,
    page_id uuid,
    space_id uuid,
    comment_id uuid,
    data jsonb,
    read_at timestamp with time zone,
    emailed_at timestamp with time zone,
    archived_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    page_verification_id uuid
);


--
-- Name: page_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_access (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    page_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    space_id uuid NOT NULL,
    access_level character varying NOT NULL,
    creator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: page_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_history (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    page_id uuid NOT NULL,
    slug_id character varying,
    title character varying,
    content jsonb,
    slug character varying,
    icon character varying,
    cover_photo character varying,
    version integer,
    last_updated_by_id uuid,
    space_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    contributor_ids uuid[] DEFAULT '{}'::uuid[]
);


--
-- Name: page_labels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_labels (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    page_id uuid NOT NULL,
    label_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: page_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_permissions (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    page_access_id uuid NOT NULL,
    user_id uuid,
    group_id uuid,
    role character varying NOT NULL,
    added_by_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT allow_either_user_id_or_group_id_check CHECK ((((user_id IS NOT NULL) AND (group_id IS NULL)) OR ((user_id IS NULL) AND (group_id IS NOT NULL))))
);


--
-- Name: page_transclusion_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_transclusion_references (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    workspace_id uuid NOT NULL,
    reference_page_id uuid NOT NULL,
    source_page_id uuid NOT NULL,
    transclusion_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: page_transclusions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_transclusions (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    workspace_id uuid NOT NULL,
    page_id uuid NOT NULL,
    transclusion_id character varying NOT NULL,
    content jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: page_verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_verifications (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    page_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    space_id uuid NOT NULL,
    type character varying DEFAULT 'expiring'::character varying NOT NULL,
    status character varying,
    mode character varying,
    period_amount integer,
    period_unit character varying,
    verified_at timestamp with time zone,
    verified_by_id uuid,
    expires_at timestamp with time zone,
    requested_at timestamp with time zone,
    requested_by_id uuid,
    rejected_at timestamp with time zone,
    rejected_by_id uuid,
    rejection_comment text,
    data jsonb,
    creator_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: page_verifiers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_verifiers (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    page_verification_id uuid NOT NULL,
    user_id uuid NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    added_by_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    slug_id character varying NOT NULL,
    title character varying,
    icon character varying,
    cover_photo character varying,
    "position" character varying,
    content jsonb,
    ydoc bytea,
    text_content text,
    tsv tsvector,
    parent_page_id uuid,
    creator_id uuid,
    last_updated_by_id uuid,
    deleted_by_id uuid,
    space_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    contributor_ids uuid[] DEFAULT '{}'::uuid[],
    is_base boolean DEFAULT false NOT NULL,
    base_schema_version integer DEFAULT 0 NOT NULL
);


--
-- Name: scim_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scim_tokens (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    name character varying NOT NULL,
    token_hash character varying NOT NULL,
    token_last_four character varying(4) NOT NULL,
    last_used_at timestamp with time zone,
    is_enabled boolean DEFAULT true NOT NULL,
    creator_id uuid,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shares (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    key character varying NOT NULL,
    page_id uuid,
    include_sub_pages boolean DEFAULT false,
    search_indexing boolean DEFAULT false,
    creator_id uuid,
    space_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: space_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.space_members (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    user_id uuid,
    group_id uuid,
    space_id uuid NOT NULL,
    role character varying NOT NULL,
    added_by_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT allow_either_user_id_or_group_id_check CHECK ((((user_id IS NOT NULL) AND (group_id IS NULL)) OR ((user_id IS NULL) AND (group_id IS NOT NULL))))
);


--
-- Name: spaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spaces (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    name character varying,
    description text,
    slug character varying NOT NULL,
    logo character varying,
    visibility character varying DEFAULT 'private'::character varying NOT NULL,
    default_role character varying DEFAULT 'writer'::character varying NOT NULL,
    creator_id uuid,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    settings jsonb,
    is_personal boolean DEFAULT false NOT NULL
);


--
-- Name: templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    title character varying,
    description text,
    content jsonb,
    ydoc bytea,
    icon character varying,
    space_id uuid,
    workspace_id uuid NOT NULL,
    creator_id uuid,
    last_updated_by_id uuid,
    collaborator_ids uuid[],
    text_content text,
    tsv tsvector,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: user_mfa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_mfa (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    user_id uuid NOT NULL,
    method character varying DEFAULT 'totp'::character varying NOT NULL,
    secret text,
    is_enabled boolean DEFAULT false,
    backup_codes text[],
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_sessions (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    user_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    device_name character varying,
    user_agent text,
    ip_address inet,
    geo_location character varying,
    last_active_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    metadata jsonb,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_tokens (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    token character varying NOT NULL,
    type character varying NOT NULL,
    user_id uuid NOT NULL,
    workspace_id uuid,
    expires_at timestamp with time zone,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    name character varying,
    email character varying NOT NULL,
    email_verified_at timestamp with time zone,
    password character varying,
    avatar_url character varying,
    role character varying,
    invited_by_id uuid,
    workspace_id uuid,
    locale character varying,
    timezone character varying,
    settings jsonb,
    last_active_at timestamp with time zone,
    last_login_at timestamp with time zone,
    deactivated_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    has_generated_password boolean DEFAULT false NOT NULL,
    scim_external_id text
);


--
-- Name: watchers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.watchers (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    user_id uuid NOT NULL,
    page_id uuid,
    space_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    type text NOT NULL,
    added_by_id uuid,
    muted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspace_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_invitations (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    email character varying,
    role character varying NOT NULL,
    token character varying NOT NULL,
    group_ids uuid[],
    invited_by_id uuid,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspaces (
    id uuid DEFAULT public.gen_uuid_v7() NOT NULL,
    name character varying,
    description character varying,
    logo character varying,
    hostname character varying,
    custom_domain character varying,
    settings jsonb,
    default_role character varying DEFAULT 'member'::character varying NOT NULL,
    email_domains character varying[] DEFAULT '{}'::character varying[],
    default_space_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    stripe_customer_id character varying,
    status character varying,
    plan character varying,
    billing_email character varying,
    trial_end_at timestamp with time zone,
    enforce_sso boolean DEFAULT false NOT NULL,
    license_key character varying,
    enforce_mfa boolean DEFAULT false,
    audit_retention_days bigint,
    trash_retention_days bigint,
    is_scim_enabled boolean DEFAULT false NOT NULL
);


--
-- Name: ai_chat_messages ai_chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chat_messages
    ADD CONSTRAINT ai_chat_messages_pkey PRIMARY KEY (id);


--
-- Name: ai_chats ai_chats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chats
    ADD CONSTRAINT ai_chats_pkey PRIMARY KEY (id);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);


--
-- Name: auth_accounts auth_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_accounts
    ADD CONSTRAINT auth_accounts_pkey PRIMARY KEY (id);


--
-- Name: auth_accounts auth_accounts_user_id_auth_provider_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_accounts
    ADD CONSTRAINT auth_accounts_user_id_auth_provider_id_unique UNIQUE (user_id, auth_provider_id);


--
-- Name: auth_providers auth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_providers
    ADD CONSTRAINT auth_providers_pkey PRIMARY KEY (id);


--
-- Name: backlinks backlinks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backlinks
    ADD CONSTRAINT backlinks_pkey PRIMARY KEY (id);


--
-- Name: backlinks backlinks_source_page_id_target_page_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backlinks
    ADD CONSTRAINT backlinks_source_page_id_target_page_id_unique UNIQUE (source_page_id, target_page_id);


--
-- Name: base_properties base_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_properties
    ADD CONSTRAINT base_properties_pkey PRIMARY KEY (page_id, id);


--
-- Name: base_rows base_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_rows
    ADD CONSTRAINT base_rows_pkey PRIMARY KEY (id);


--
-- Name: base_views base_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_views
    ADD CONSTRAINT base_views_pkey PRIMARY KEY (id);


--
-- Name: billing billing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing
    ADD CONSTRAINT billing_pkey PRIMARY KEY (id);


--
-- Name: billing billing_stripe_subscription_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing
    ADD CONSTRAINT billing_stripe_subscription_id_unique UNIQUE (stripe_subscription_id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: file_tasks file_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_tasks
    ADD CONSTRAINT file_tasks_pkey PRIMARY KEY (id);


--
-- Name: group_users group_users_group_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_users
    ADD CONSTRAINT group_users_group_id_user_id_unique UNIQUE (group_id, user_id);


--
-- Name: group_users group_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_users
    ADD CONSTRAINT group_users_pkey PRIMARY KEY (id);


--
-- Name: groups groups_name_workspace_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_name_workspace_id_unique UNIQUE (name, workspace_id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: workspace_invitations invitations_email_workspace_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT invitations_email_workspace_id_unique UNIQUE (email, workspace_id);


--
-- Name: kysely_migration_lock kysely_migration_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kysely_migration_lock
    ADD CONSTRAINT kysely_migration_lock_pkey PRIMARY KEY (id);


--
-- Name: kysely_migration kysely_migration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kysely_migration
    ADD CONSTRAINT kysely_migration_pkey PRIMARY KEY (name);


--
-- Name: labels labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: page_permissions page_access_group_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_permissions
    ADD CONSTRAINT page_access_group_unique UNIQUE (page_access_id, group_id);


--
-- Name: page_access page_access_page_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_access
    ADD CONSTRAINT page_access_page_id_key UNIQUE (page_id);


--
-- Name: page_access page_access_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_access
    ADD CONSTRAINT page_access_pkey PRIMARY KEY (id);


--
-- Name: page_permissions page_access_user_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_permissions
    ADD CONSTRAINT page_access_user_unique UNIQUE (page_access_id, user_id);


--
-- Name: page_history page_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_history
    ADD CONSTRAINT page_history_pkey PRIMARY KEY (id);


--
-- Name: page_labels page_labels_page_id_label_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_labels
    ADD CONSTRAINT page_labels_page_id_label_id_unique UNIQUE (page_id, label_id);


--
-- Name: page_labels page_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_labels
    ADD CONSTRAINT page_labels_pkey PRIMARY KEY (id);


--
-- Name: page_permissions page_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_permissions
    ADD CONSTRAINT page_permissions_pkey PRIMARY KEY (id);


--
-- Name: page_transclusion_references page_transclusion_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_transclusion_references
    ADD CONSTRAINT page_transclusion_references_pkey PRIMARY KEY (id);


--
-- Name: page_transclusion_references page_transclusion_references_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_transclusion_references
    ADD CONSTRAINT page_transclusion_references_unique UNIQUE (reference_page_id, source_page_id, transclusion_id);


--
-- Name: page_transclusions page_transclusions_page_transclusion_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_transclusions
    ADD CONSTRAINT page_transclusions_page_transclusion_unique UNIQUE (page_id, transclusion_id);


--
-- Name: page_transclusions page_transclusions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_transclusions
    ADD CONSTRAINT page_transclusions_pkey PRIMARY KEY (id);


--
-- Name: page_verifications page_verifications_page_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifications
    ADD CONSTRAINT page_verifications_page_id_key UNIQUE (page_id);


--
-- Name: page_verifications page_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifications
    ADD CONSTRAINT page_verifications_pkey PRIMARY KEY (id);


--
-- Name: page_verifiers page_verifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifiers
    ADD CONSTRAINT page_verifiers_pkey PRIMARY KEY (id);


--
-- Name: page_verifiers page_verifiers_verification_user_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifiers
    ADD CONSTRAINT page_verifiers_verification_user_unique UNIQUE (page_verification_id, user_id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: pages pages_slug_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_slug_id_unique UNIQUE (slug_id);


--
-- Name: scim_tokens scim_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scim_tokens
    ADD CONSTRAINT scim_tokens_pkey PRIMARY KEY (id);


--
-- Name: shares shares_key_workspace_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_key_workspace_id_unique UNIQUE (key, workspace_id);


--
-- Name: shares shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: space_members space_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT space_members_pkey PRIMARY KEY (id);


--
-- Name: space_members space_members_space_id_group_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT space_members_space_id_group_id_unique UNIQUE (space_id, group_id);


--
-- Name: space_members space_members_space_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT space_members_space_id_user_id_unique UNIQUE (space_id, user_id);


--
-- Name: spaces spaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT spaces_pkey PRIMARY KEY (id);


--
-- Name: spaces spaces_slug_workspace_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT spaces_slug_workspace_id_unique UNIQUE (slug, workspace_id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: user_mfa user_mfa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_mfa
    ADD CONSTRAINT user_mfa_pkey PRIMARY KEY (id);


--
-- Name: user_mfa user_mfa_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_mfa
    ADD CONSTRAINT user_mfa_user_id_unique UNIQUE (user_id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: user_tokens user_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_pkey PRIMARY KEY (id);


--
-- Name: users users_email_workspace_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_workspace_id_unique UNIQUE (email, workspace_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: watchers watchers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watchers
    ADD CONSTRAINT watchers_pkey PRIMARY KEY (id);


--
-- Name: workspace_invitations workspace_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_pkey PRIMARY KEY (id);


--
-- Name: workspaces workspaces_custom_domain_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_custom_domain_unique UNIQUE (custom_domain);


--
-- Name: workspaces workspaces_hostname_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_hostname_unique UNIQUE (hostname);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: workspaces workspaces_stripe_customer_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_stripe_customer_id_unique UNIQUE (stripe_customer_id);


--
-- Name: attachments_tsv_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attachments_tsv_idx ON public.attachments USING gin (tsv);


--
-- Name: base_properties_page_name_alive_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX base_properties_page_name_alive_unique ON public.base_properties USING btree (page_id, lower(TRIM(BOTH FROM name))) WHERE (deleted_at IS NULL);


--
-- Name: idx_ai_chat_messages_chat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_chat_messages_chat_id ON public.ai_chat_messages USING btree (chat_id, id);


--
-- Name: idx_ai_chat_messages_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_chat_messages_tsv ON public.ai_chat_messages USING gin (tsv);


--
-- Name: idx_ai_chats_workspace_creator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_chats_workspace_creator ON public.ai_chats USING btree (workspace_id, creator_id, id);


--
-- Name: idx_api_keys_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_api_keys_workspace_id ON public.api_keys USING btree (workspace_id);


--
-- Name: idx_attachments_ai_chat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_attachments_ai_chat_id ON public.attachments USING btree (ai_chat_id);


--
-- Name: idx_attachments_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_attachments_page_id ON public.attachments USING btree (page_id);


--
-- Name: idx_attachments_space_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_attachments_space_id ON public.attachments USING btree (space_id);


--
-- Name: idx_attachments_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_attachments_workspace_id ON public.attachments USING btree (workspace_id);


--
-- Name: idx_audit_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_workspace_id ON public.audit USING btree (workspace_id, id DESC);


--
-- Name: idx_auth_accounts_provider_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_auth_accounts_provider_user_id ON public.auth_accounts USING btree (provider_user_id, auth_provider_id);


--
-- Name: idx_auth_providers_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_auth_providers_workspace_id ON public.auth_providers USING btree (workspace_id);


--
-- Name: idx_backlinks_target_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_backlinks_target_page_id ON public.backlinks USING btree (target_page_id);


--
-- Name: idx_base_properties_page_alive; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_base_properties_page_alive ON public.base_properties USING btree (page_id, "position" COLLATE "C", id) WHERE (deleted_at IS NULL);


--
-- Name: idx_base_properties_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_base_properties_page_id ON public.base_properties USING btree (page_id);


--
-- Name: idx_base_rows_page_alive; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_base_rows_page_alive ON public.base_rows USING btree (page_id, "position" COLLATE "C", id) WHERE (deleted_at IS NULL);


--
-- Name: idx_base_rows_page_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_base_rows_page_created ON public.base_rows USING btree (page_id, created_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: idx_base_rows_page_updated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_base_rows_page_updated ON public.base_rows USING btree (page_id, updated_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: idx_base_views_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_base_views_page_id ON public.base_views USING btree (page_id);


--
-- Name: idx_comments_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comments_page_id ON public.comments USING btree (page_id);


--
-- Name: idx_comments_parent_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comments_parent_comment_id ON public.comments USING btree (parent_comment_id);


--
-- Name: idx_favorites_user_page; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_favorites_user_page ON public.favorites USING btree (user_id, page_id) WHERE (page_id IS NOT NULL);


--
-- Name: idx_favorites_user_space; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_favorites_user_space ON public.favorites USING btree (user_id, space_id) WHERE (space_id IS NOT NULL);


--
-- Name: idx_favorites_user_template; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_favorites_user_template ON public.favorites USING btree (user_id, template_id) WHERE (template_id IS NOT NULL);


--
-- Name: idx_favorites_user_workspace_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_favorites_user_workspace_type ON public.favorites USING btree (user_id, workspace_id, type);


--
-- Name: idx_file_tasks_page_export; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_file_tasks_page_export ON public.file_tasks USING btree (page_id, workspace_id) WHERE (((type)::text = 'export'::text) AND (deleted_at IS NULL));


--
-- Name: idx_group_users_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_group_users_user_id ON public.group_users USING btree (user_id);


--
-- Name: idx_groups_name_lower_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_groups_name_lower_workspace ON public.groups USING btree (lower((name)::text), workspace_id);


--
-- Name: idx_groups_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groups_workspace_id ON public.groups USING btree (workspace_id);


--
-- Name: idx_groups_workspace_scim_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_groups_workspace_scim_external_id ON public.groups USING btree (workspace_id, scim_external_id) WHERE (scim_external_id IS NOT NULL);


--
-- Name: idx_notifications_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_comment_id ON public.notifications USING btree (comment_id);


--
-- Name: idx_notifications_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_page_id ON public.notifications USING btree (page_id);


--
-- Name: idx_notifications_space_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_space_id ON public.notifications USING btree (space_id);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id, id DESC);


--
-- Name: idx_notifications_user_unread; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_user_unread ON public.notifications USING btree (user_id) WHERE (read_at IS NULL);


--
-- Name: idx_page_access_space; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_page_access_space ON public.page_access USING btree (space_id);


--
-- Name: idx_page_history_page_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_page_history_page_created ON public.page_history USING btree (page_id, created_at DESC);


--
-- Name: idx_page_permissions_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_page_permissions_group ON public.page_permissions USING btree (group_id);


--
-- Name: idx_page_permissions_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_page_permissions_user ON public.page_permissions USING btree (user_id);


--
-- Name: idx_page_transclusion_references_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_page_transclusion_references_source ON public.page_transclusion_references USING btree (source_page_id, transclusion_id);


--
-- Name: idx_page_transclusion_references_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_page_transclusion_references_workspace ON public.page_transclusion_references USING btree (workspace_id);


--
-- Name: idx_page_transclusions_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_page_transclusions_workspace ON public.page_transclusions USING btree (workspace_id);


--
-- Name: idx_page_verifications_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_page_verifications_expires_at ON public.page_verifications USING btree (expires_at) WHERE (expires_at IS NOT NULL);


--
-- Name: idx_page_verifications_space_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_page_verifications_space_id ON public.page_verifications USING btree (space_id);


--
-- Name: idx_page_verifications_workspace_id_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_page_verifications_workspace_id_id ON public.page_verifications USING btree (workspace_id, id DESC);


--
-- Name: idx_page_verifiers_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_page_verifiers_user_id ON public.page_verifiers USING btree (user_id);


--
-- Name: idx_pages_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pages_creator_id ON public.pages USING btree (creator_id);


--
-- Name: idx_pages_is_base; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pages_is_base ON public.pages USING btree (space_id, "position" COLLATE "C") WHERE ((is_base = true) AND (deleted_at IS NULL));


--
-- Name: idx_pages_parent_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pages_parent_page_id ON public.pages USING btree (parent_page_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_pages_space_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pages_space_deleted ON public.pages USING btree (space_id, deleted_at DESC) WHERE (deleted_at IS NOT NULL);


--
-- Name: idx_pages_space_parent_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pages_space_parent_position ON public.pages USING btree (space_id, parent_page_id, "position" COLLATE "C") WHERE (deleted_at IS NULL);


--
-- Name: idx_pages_space_updated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pages_space_updated ON public.pages USING btree (space_id, updated_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: idx_pages_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pages_workspace_id ON public.pages USING btree (workspace_id);


--
-- Name: idx_scim_tokens_token_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_scim_tokens_token_hash ON public.scim_tokens USING btree (token_hash);


--
-- Name: idx_scim_tokens_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_scim_tokens_workspace_id ON public.scim_tokens USING btree (workspace_id);


--
-- Name: idx_shares_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shares_page_id ON public.shares USING btree (page_id);


--
-- Name: idx_space_members_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_space_members_group_id ON public.space_members USING btree (group_id);


--
-- Name: idx_space_members_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_space_members_user_id ON public.space_members USING btree (user_id);


--
-- Name: idx_spaces_slug_lower_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_spaces_slug_lower_workspace ON public.spaces USING btree (lower((slug)::text), workspace_id);


--
-- Name: idx_spaces_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_spaces_workspace_id ON public.spaces USING btree (workspace_id);


--
-- Name: idx_templates_space_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_space_id ON public.templates USING btree (space_id);


--
-- Name: idx_templates_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_workspace_id ON public.templates USING btree (workspace_id);


--
-- Name: idx_user_sessions_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_sessions_active ON public.user_sessions USING btree (user_id, workspace_id, last_active_at DESC) WHERE (revoked_at IS NULL);


--
-- Name: idx_user_sessions_revoked; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_sessions_revoked ON public.user_sessions USING btree (expires_at) WHERE (revoked_at IS NOT NULL);


--
-- Name: idx_user_sessions_user_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_sessions_user_workspace ON public.user_sessions USING btree (user_id, workspace_id);


--
-- Name: idx_users_workspace_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_workspace_deleted ON public.users USING btree (workspace_id, deleted_at);


--
-- Name: idx_users_workspace_scim_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_users_workspace_scim_external_id ON public.users USING btree (workspace_id, scim_external_id) WHERE (scim_external_id IS NOT NULL);


--
-- Name: idx_watchers_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_watchers_page_id ON public.watchers USING btree (page_id);


--
-- Name: idx_watchers_space_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_watchers_space_id ON public.watchers USING btree (space_id);


--
-- Name: idx_watchers_user_page; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_watchers_user_page ON public.watchers USING btree (user_id, page_id) WHERE (page_id IS NOT NULL);


--
-- Name: idx_watchers_user_space; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_watchers_user_space ON public.watchers USING btree (user_id, space_id) WHERE (page_id IS NULL);


--
-- Name: idx_watchers_user_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_watchers_user_workspace ON public.watchers USING btree (user_id, workspace_id);


--
-- Name: idx_workspace_invitations_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspace_invitations_workspace_id ON public.workspace_invitations USING btree (workspace_id);


--
-- Name: idx_workspaces_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspaces_created_at ON public.workspaces USING btree (created_at);


--
-- Name: idx_workspaces_hostname_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_workspaces_hostname_lower ON public.workspaces USING btree (lower((hostname)::text));


--
-- Name: labels_workspace_id_type_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX labels_workspace_id_type_name_unique ON public.labels USING btree (workspace_id, type, name);


--
-- Name: page_labels_label_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX page_labels_label_id_idx ON public.page_labels USING btree (label_id);


--
-- Name: pages_tsv_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pages_tsv_idx ON public.pages USING gin (tsv);


--
-- Name: spaces_personal_creator_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX spaces_personal_creator_unique ON public.spaces USING btree (creator_id) WHERE ((is_personal = true) AND (deleted_at IS NULL));


--
-- Name: templates_tsv_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX templates_tsv_idx ON public.templates USING gin (tsv);


--
-- Name: ai_chat_messages ai_chat_messages_tsvector_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ai_chat_messages_tsvector_update BEFORE INSERT OR UPDATE ON public.ai_chat_messages FOR EACH ROW EXECUTE FUNCTION public.ai_chat_messages_tsvector_trigger();


--
-- Name: pages pages_tsvector_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER pages_tsvector_update BEFORE INSERT OR UPDATE ON public.pages FOR EACH ROW EXECUTE FUNCTION public.pages_tsvector_trigger();


--
-- Name: templates templates_tsvector_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER templates_tsvector_update BEFORE INSERT OR UPDATE ON public.templates FOR EACH ROW EXECUTE FUNCTION public.templates_tsvector_trigger();


--
-- Name: ai_chat_messages ai_chat_messages_chat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chat_messages
    ADD CONSTRAINT ai_chat_messages_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.ai_chats(id) ON DELETE CASCADE;


--
-- Name: ai_chat_messages ai_chat_messages_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chat_messages
    ADD CONSTRAINT ai_chat_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: ai_chat_messages ai_chat_messages_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chat_messages
    ADD CONSTRAINT ai_chat_messages_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: ai_chats ai_chats_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chats
    ADD CONSTRAINT ai_chats_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: ai_chats ai_chats_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chats
    ADD CONSTRAINT ai_chats_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: api_keys api_keys_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: api_keys api_keys_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: attachments attachments_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: attachments attachments_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: audit audit_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: auth_accounts auth_accounts_auth_provider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_accounts
    ADD CONSTRAINT auth_accounts_auth_provider_id_fkey FOREIGN KEY (auth_provider_id) REFERENCES public.auth_providers(id) ON DELETE CASCADE;


--
-- Name: auth_accounts auth_accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_accounts
    ADD CONSTRAINT auth_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: auth_accounts auth_accounts_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_accounts
    ADD CONSTRAINT auth_accounts_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: auth_providers auth_providers_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_providers
    ADD CONSTRAINT auth_providers_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: auth_providers auth_providers_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_providers
    ADD CONSTRAINT auth_providers_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: backlinks backlinks_source_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backlinks
    ADD CONSTRAINT backlinks_source_page_id_fkey FOREIGN KEY (source_page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: backlinks backlinks_target_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backlinks
    ADD CONSTRAINT backlinks_target_page_id_fkey FOREIGN KEY (target_page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: backlinks backlinks_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backlinks
    ADD CONSTRAINT backlinks_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: base_properties base_properties_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_properties
    ADD CONSTRAINT base_properties_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: base_properties base_properties_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_properties
    ADD CONSTRAINT base_properties_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: base_rows base_rows_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_rows
    ADD CONSTRAINT base_rows_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: base_rows base_rows_last_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_rows
    ADD CONSTRAINT base_rows_last_updated_by_id_fkey FOREIGN KEY (last_updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: base_rows base_rows_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_rows
    ADD CONSTRAINT base_rows_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: base_rows base_rows_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_rows
    ADD CONSTRAINT base_rows_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: base_views base_views_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_views
    ADD CONSTRAINT base_views_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: base_views base_views_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_views
    ADD CONSTRAINT base_views_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: base_views base_views_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_views
    ADD CONSTRAINT base_views_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: billing billing_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing
    ADD CONSTRAINT billing_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: comments comments_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: comments comments_last_edited_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_last_edited_by_id_fkey FOREIGN KEY (last_edited_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: comments comments_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: comments comments_parent_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: comments comments_resolved_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_resolved_by_id_fkey FOREIGN KEY (resolved_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: comments comments_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: comments comments_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: favorites favorites_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.templates(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: file_tasks file_tasks_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_tasks
    ADD CONSTRAINT file_tasks_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: file_tasks file_tasks_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_tasks
    ADD CONSTRAINT file_tasks_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE SET NULL;


--
-- Name: file_tasks file_tasks_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_tasks
    ADD CONSTRAINT file_tasks_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: file_tasks file_tasks_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_tasks
    ADD CONSTRAINT file_tasks_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: group_users group_users_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_users
    ADD CONSTRAINT group_users_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: group_users group_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_users
    ADD CONSTRAINT group_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: groups groups_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: groups groups_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: labels labels_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_page_verification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_page_verification_id_fkey FOREIGN KEY (page_verification_id) REFERENCES public.page_verifications(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: page_access page_access_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_access
    ADD CONSTRAINT page_access_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: page_access page_access_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_access
    ADD CONSTRAINT page_access_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: page_access page_access_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_access
    ADD CONSTRAINT page_access_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: page_access page_access_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_access
    ADD CONSTRAINT page_access_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: page_history page_history_last_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_history
    ADD CONSTRAINT page_history_last_updated_by_id_fkey FOREIGN KEY (last_updated_by_id) REFERENCES public.users(id);


--
-- Name: page_history page_history_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_history
    ADD CONSTRAINT page_history_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: page_history page_history_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_history
    ADD CONSTRAINT page_history_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: page_history page_history_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_history
    ADD CONSTRAINT page_history_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: page_labels page_labels_label_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_labels
    ADD CONSTRAINT page_labels_label_id_fkey FOREIGN KEY (label_id) REFERENCES public.labels(id) ON DELETE CASCADE;


--
-- Name: page_labels page_labels_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_labels
    ADD CONSTRAINT page_labels_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: page_permissions page_permissions_added_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_permissions
    ADD CONSTRAINT page_permissions_added_by_id_fkey FOREIGN KEY (added_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: page_permissions page_permissions_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_permissions
    ADD CONSTRAINT page_permissions_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: page_permissions page_permissions_page_access_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_permissions
    ADD CONSTRAINT page_permissions_page_access_id_fkey FOREIGN KEY (page_access_id) REFERENCES public.page_access(id) ON DELETE CASCADE;


--
-- Name: page_permissions page_permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_permissions
    ADD CONSTRAINT page_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: page_transclusion_references page_transclusion_references_reference_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_transclusion_references
    ADD CONSTRAINT page_transclusion_references_reference_page_id_fkey FOREIGN KEY (reference_page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: page_transclusion_references page_transclusion_references_source_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_transclusion_references
    ADD CONSTRAINT page_transclusion_references_source_page_id_fkey FOREIGN KEY (source_page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: page_transclusion_references page_transclusion_references_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_transclusion_references
    ADD CONSTRAINT page_transclusion_references_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: page_transclusions page_transclusions_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_transclusions
    ADD CONSTRAINT page_transclusions_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: page_transclusions page_transclusions_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_transclusions
    ADD CONSTRAINT page_transclusions_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: page_verifications page_verifications_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifications
    ADD CONSTRAINT page_verifications_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: page_verifications page_verifications_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifications
    ADD CONSTRAINT page_verifications_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: page_verifications page_verifications_rejected_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifications
    ADD CONSTRAINT page_verifications_rejected_by_id_fkey FOREIGN KEY (rejected_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: page_verifications page_verifications_requested_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifications
    ADD CONSTRAINT page_verifications_requested_by_id_fkey FOREIGN KEY (requested_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: page_verifications page_verifications_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifications
    ADD CONSTRAINT page_verifications_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: page_verifications page_verifications_verified_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifications
    ADD CONSTRAINT page_verifications_verified_by_id_fkey FOREIGN KEY (verified_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: page_verifications page_verifications_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifications
    ADD CONSTRAINT page_verifications_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: page_verifiers page_verifiers_added_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifiers
    ADD CONSTRAINT page_verifiers_added_by_id_fkey FOREIGN KEY (added_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: page_verifiers page_verifiers_page_verification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifiers
    ADD CONSTRAINT page_verifiers_page_verification_id_fkey FOREIGN KEY (page_verification_id) REFERENCES public.page_verifications(id) ON DELETE CASCADE;


--
-- Name: page_verifiers page_verifiers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_verifiers
    ADD CONSTRAINT page_verifiers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: pages pages_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: pages pages_deleted_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_deleted_by_id_fkey FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: pages pages_last_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_last_updated_by_id_fkey FOREIGN KEY (last_updated_by_id) REFERENCES public.users(id);


--
-- Name: pages pages_parent_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_parent_page_id_fkey FOREIGN KEY (parent_page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: pages pages_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: pages pages_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: scim_tokens scim_tokens_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scim_tokens
    ADD CONSTRAINT scim_tokens_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: scim_tokens scim_tokens_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scim_tokens
    ADD CONSTRAINT scim_tokens_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: shares shares_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: shares shares_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: shares shares_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: shares shares_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: space_members space_members_added_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT space_members_added_by_id_fkey FOREIGN KEY (added_by_id) REFERENCES public.users(id);


--
-- Name: space_members space_members_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT space_members_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: space_members space_members_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT space_members_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: space_members space_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT space_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: spaces spaces_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT spaces_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: spaces spaces_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT spaces_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: templates templates_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: templates templates_last_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_last_updated_by_id_fkey FOREIGN KEY (last_updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: templates templates_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: templates templates_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: user_mfa user_mfa_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_mfa
    ADD CONSTRAINT user_mfa_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_mfa user_mfa_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_mfa
    ADD CONSTRAINT user_mfa_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_sessions user_sessions_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: user_tokens user_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_tokens user_tokens_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: users users_invited_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_invited_by_id_fkey FOREIGN KEY (invited_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: users users_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: watchers watchers_added_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watchers
    ADD CONSTRAINT watchers_added_by_id_fkey FOREIGN KEY (added_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: watchers watchers_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watchers
    ADD CONSTRAINT watchers_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: watchers watchers_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watchers
    ADD CONSTRAINT watchers_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;


--
-- Name: watchers watchers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watchers
    ADD CONSTRAINT watchers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: watchers watchers_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watchers
    ADD CONSTRAINT watchers_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: workspace_invitations workspace_invitations_invited_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_invited_by_id_fkey FOREIGN KEY (invited_by_id) REFERENCES public.users(id);


--
-- Name: workspace_invitations workspace_invitations_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: workspaces workspaces_default_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_default_space_id_fkey FOREIGN KEY (default_space_id) REFERENCES public.spaces(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--


