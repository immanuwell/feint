--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: handle_page_update(); Type: FUNCTION; Schema: public; Owner: penpot
--

CREATE FUNCTION public.handle_page_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    current_dt timestamptz := clock_timestamp();
    proj_id uuid;
  BEGIN
    NEW.modified_at := current_dt;

    UPDATE file
       SET modified_at = current_dt
     WHERE id = OLD.file_id
 RETURNING project_id
      INTO STRICT proj_id;

    --- Update projects modified_at attribute when a
    --- page of that project is modified.
    UPDATE project
       SET modified_at = current_dt
     WHERE id = proj_id;

    RETURN NEW;
  END;
$$;



--
-- Name: raise_deletion_protection(); Type: FUNCTION; Schema: public; Owner: penpot
--

CREATE FUNCTION public.raise_deletion_protection() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RAISE EXCEPTION 'unable to proceed to delete row on "%"', TG_TABLE_NAME
          USING HINT = 'disable deletion protection with "SET rules.deletion_protection TO off"';
    RETURN NULL;
  END;
$$;



SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: access_token; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.access_token (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    profile_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    token text NOT NULL,
    perms text[],
    expires_at timestamp with time zone,
    type text
);
ALTER TABLE ONLY public.access_token ALTER COLUMN name SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.access_token ALTER COLUMN token SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.access_token ALTER COLUMN perms SET STORAGE EXTERNAL;



--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.audit_log (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    archived_at timestamp with time zone,
    profile_id uuid NOT NULL,
    props jsonb,
    ip_addr inet,
    tracked_at timestamp with time zone DEFAULT now(),
    source text,
    context jsonb
);
ALTER TABLE ONLY public.audit_log ALTER COLUMN name SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.audit_log ALTER COLUMN type SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.audit_log ALTER COLUMN props SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.audit_log ALTER COLUMN source SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.audit_log ALTER COLUMN context SET STORAGE EXTERNAL;



--
-- Name: comment; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.comment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    thread_id uuid NOT NULL,
    owner_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    content text NOT NULL,
    mentions uuid[] DEFAULT '{}'::uuid[]
);
ALTER TABLE ONLY public.comment ALTER COLUMN content SET STORAGE EXTERNAL;



--
-- Name: comment_thread; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.comment_thread (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    file_id uuid NOT NULL,
    owner_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    page_id uuid NOT NULL,
    participants jsonb NOT NULL,
    seqn integer DEFAULT 0 NOT NULL,
    "position" point NOT NULL,
    is_resolved boolean DEFAULT false NOT NULL,
    page_name text,
    frame_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
    mentions uuid[] DEFAULT '{}'::uuid[]
);
ALTER TABLE ONLY public.comment_thread ALTER COLUMN participants SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.comment_thread ALTER COLUMN page_name SET STORAGE EXTERNAL;



--
-- Name: comment_thread_status; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.comment_thread_status (
    thread_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);



--
-- Name: file; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    project_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    deleted_at timestamp with time zone,
    name text NOT NULL,
    is_shared boolean DEFAULT false NOT NULL,
    has_media_trimmed boolean DEFAULT false,
    revn bigint DEFAULT 0 NOT NULL,
    data bytea,
    ignore_sync_until timestamp with time zone,
    comment_thread_seqn integer DEFAULT 0,
    data_backend text,
    features text[],
    version integer,
    data_ref_id uuid,
    vern integer DEFAULT 0 NOT NULL
)
WITH (fillfactor='50');
ALTER TABLE ONLY public.file ALTER COLUMN name SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.file ALTER COLUMN data SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.file ALTER COLUMN data_backend SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.file ALTER COLUMN features SET STORAGE EXTERNAL;



--
-- Name: file_change; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_change (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    file_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    session_id uuid,
    revn bigint DEFAULT 0 NOT NULL,
    data bytea,
    changes bytea,
    profile_id uuid,
    features text[],
    label text,
    data_backend text,
    data_ref_id uuid,
    version integer,
    created_by text DEFAULT 'system'::text NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    deleted_at timestamp with time zone,
    migrations text[],
    locked_by uuid
);
ALTER TABLE ONLY public.file_change ALTER COLUMN data SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.file_change ALTER COLUMN changes SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.file_change ALTER COLUMN features SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.file_change ALTER COLUMN label SET STORAGE EXTERNAL;



--
-- Name: COLUMN file_change.locked_by; Type: COMMENT; Schema: public; Owner: penpot
--

COMMENT ON COLUMN public.file_change.locked_by IS 'Profile ID of user who has locked this version. Only the creator can lock/unlock their own versions. Locked versions cannot be deleted by others.';


--
-- Name: file_data; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
)
PARTITION BY HASH (file_id);



--
-- Name: file_data_00; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_00 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_01; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_01 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_02; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_02 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_03; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_03 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_04; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_04 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_05; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_05 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_06; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_06 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_07; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_07 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_08; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_08 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_09; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_09 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_10; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_10 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_11; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_11 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_12; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_12 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_13; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_13 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_14; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_14 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_15; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_15 (
    file_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    backend text,
    metadata jsonb,
    data bytea
);



--
-- Name: file_data_fragment; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_data_fragment (
    id uuid NOT NULL,
    file_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb,
    deleted_at timestamp with time zone,
    data bytea,
    data_backend text,
    data_ref_id uuid
);
ALTER TABLE ONLY public.file_data_fragment ALTER COLUMN metadata SET STORAGE EXTERNAL;



--
-- Name: file_library_rel; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_library_rel (
    file_id uuid NOT NULL,
    library_file_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    synced_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);



--
-- Name: TABLE file_library_rel; Type: COMMENT; Schema: public; Owner: penpot
--

COMMENT ON TABLE public.file_library_rel IS 'Relation between files and the shared library files they use (NM)';


--
-- Name: COLUMN file_library_rel.synced_at; Type: COMMENT; Schema: public; Owner: penpot
--

COMMENT ON COLUMN public.file_library_rel.synced_at IS 'DEPRECATED: will be removed in a future migration; kept temporarily for backward compatibility';


--
-- Name: file_library_sync; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_library_sync (
    file_id uuid NOT NULL,
    library_file_id uuid NOT NULL,
    synced_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);



--
-- Name: file_media_object; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_media_object (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    deleted_at timestamp with time zone,
    name text NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    mtype text NOT NULL,
    file_id uuid NOT NULL,
    is_local boolean DEFAULT false NOT NULL,
    media_id uuid NOT NULL,
    thumbnail_id uuid
);
ALTER TABLE ONLY public.file_media_object ALTER COLUMN name SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.file_media_object ALTER COLUMN mtype SET STORAGE EXTERNAL;



--
-- Name: file_migration; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_migration (
    file_id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);



--
-- Name: file_object_thumbnail; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_object_thumbnail (
    file_id uuid NOT NULL,
    object_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    data text,
    media_id uuid
);
ALTER TABLE ONLY public.file_object_thumbnail ALTER COLUMN data SET STORAGE EXTERNAL;



--
-- Name: file_profile_rel; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_profile_rel (
    file_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    is_owner boolean DEFAULT false,
    is_admin boolean DEFAULT false,
    can_edit boolean DEFAULT false
);



--
-- Name: TABLE file_profile_rel; Type: COMMENT; Schema: public; Owner: penpot
--

COMMENT ON TABLE public.file_profile_rel IS 'Relation between files and profiles (NM)';


--
-- Name: file_tagged_object_thumbnail; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_tagged_object_thumbnail (
    file_id uuid NOT NULL,
    tag text DEFAULT 'frame'::text NOT NULL,
    object_id text NOT NULL,
    media_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);



--
-- Name: file_thumbnail; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.file_thumbnail (
    file_id uuid NOT NULL,
    revn bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    data text,
    props jsonb,
    media_id uuid
);
ALTER TABLE ONLY public.file_thumbnail ALTER COLUMN data SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.file_thumbnail ALTER COLUMN props SET STORAGE EXTERNAL;



--
-- Name: global_complaint_report; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.global_complaint_report (
    email text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    type text NOT NULL,
    content jsonb
);
ALTER TABLE ONLY public.global_complaint_report ALTER COLUMN type SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.global_complaint_report ALTER COLUMN content SET STORAGE EXTERNAL;



--
-- Name: http_session; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.http_session (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    profile_id uuid NOT NULL,
    user_agent text,
    updated_at timestamp with time zone
);
ALTER TABLE ONLY public.http_session ALTER COLUMN id SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.http_session ALTER COLUMN user_agent SET STORAGE EXTERNAL;



--
-- Name: http_session_v2; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.http_session_v2 (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    profile_id uuid,
    user_agent text,
    sso_provider_id uuid,
    sso_session_id text,
    props jsonb
);



--
-- Name: migrations; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.migrations (
    module text,
    step text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);



--
-- Name: presence; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.presence (
    file_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    session_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);



--
-- Name: profile; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.profile (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    deleted_at timestamp with time zone,
    fullname text DEFAULT ''::text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    lang text,
    theme text,
    is_demo boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    props jsonb,
    photo_id uuid,
    is_muted boolean DEFAULT false,
    auth_backend text,
    is_blocked boolean DEFAULT false,
    default_project_id uuid,
    default_team_id uuid
);
ALTER TABLE ONLY public.profile ALTER COLUMN fullname SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.profile ALTER COLUMN email SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.profile ALTER COLUMN password SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.profile ALTER COLUMN lang SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.profile ALTER COLUMN theme SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.profile ALTER COLUMN props SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.profile ALTER COLUMN auth_backend SET STORAGE EXTERNAL;



--
-- Name: profile_complaint_report; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.profile_complaint_report (
    profile_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    type text NOT NULL,
    content jsonb
);
ALTER TABLE ONLY public.profile_complaint_report ALTER COLUMN type SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.profile_complaint_report ALTER COLUMN content SET STORAGE EXTERNAL;



--
-- Name: project; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.project (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    team_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    deleted_at timestamp with time zone,
    is_default boolean DEFAULT false NOT NULL,
    name text NOT NULL
);
ALTER TABLE ONLY public.project ALTER COLUMN name SET STORAGE EXTERNAL;



--
-- Name: project_profile_rel; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.project_profile_rel (
    profile_id uuid NOT NULL,
    project_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    is_owner boolean DEFAULT false,
    is_admin boolean DEFAULT false,
    can_edit boolean DEFAULT false,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL
);



--
-- Name: scheduled_task; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.scheduled_task (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    cron_expr text NOT NULL
);
ALTER TABLE ONLY public.scheduled_task ALTER COLUMN id SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.scheduled_task ALTER COLUMN cron_expr SET STORAGE EXTERNAL;



--
-- Name: scheduled_task_history; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.scheduled_task_history (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    task_id text NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    is_error boolean DEFAULT false NOT NULL,
    reason text
);



--
-- Name: server_error_report; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.server_error_report (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    content jsonb,
    version integer DEFAULT 1
);
ALTER TABLE ONLY public.server_error_report ALTER COLUMN content SET STORAGE EXTERNAL;



--
-- Name: server_prop; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.server_prop (
    id text NOT NULL,
    content jsonb,
    preload boolean DEFAULT false
);
ALTER TABLE ONLY public.server_prop ALTER COLUMN id SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.server_prop ALTER COLUMN content SET STORAGE EXTERNAL;



--
-- Name: share_link; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.share_link (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    file_id uuid NOT NULL,
    owner_id uuid,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    pages uuid[],
    flags text[],
    who_comment text DEFAULT 'team'::text NOT NULL,
    who_inspect text DEFAULT 'team'::text NOT NULL
);



--
-- Name: sso_provider; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.sso_provider (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    type text NOT NULL,
    domain text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    base_uri text NOT NULL,
    token_uri text,
    auth_uri text,
    user_uri text,
    jwks_uri text,
    logout_uri text,
    roles_attr text,
    email_attr text,
    name_attr text,
    user_info_source text DEFAULT 'token'::text NOT NULL,
    scopes text[],
    roles text[],
    CONSTRAINT sso_provider_type_check CHECK ((type = 'oidc'::text)),
    CONSTRAINT sso_provider_user_info_source_check CHECK ((user_info_source = ANY (ARRAY['token'::text, 'userinfo'::text, 'auto'::text])))
);



--
-- Name: storage_object; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.storage_object (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    size bigint DEFAULT 0 NOT NULL,
    backend text NOT NULL,
    metadata jsonb,
    touched_at timestamp with time zone
)
WITH (fillfactor='60');
ALTER TABLE ONLY public.storage_object ALTER COLUMN backend SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.storage_object ALTER COLUMN metadata SET STORAGE EXTERNAL;



--
-- Name: task; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.task (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    scheduled_at timestamp with time zone NOT NULL,
    priority smallint DEFAULT 100,
    queue text NOT NULL,
    name text NOT NULL,
    props jsonb NOT NULL,
    error text,
    retry_num smallint DEFAULT 0 NOT NULL,
    max_retries smallint DEFAULT 3 NOT NULL,
    status text DEFAULT 'new'::text NOT NULL,
    label text
)
WITH (fillfactor='60');
ALTER TABLE ONLY public.task ALTER COLUMN queue SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.task ALTER COLUMN name SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.task ALTER COLUMN props SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.task ALTER COLUMN error SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.task ALTER COLUMN status SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.task ALTER COLUMN label SET STORAGE EXTERNAL;



--
-- Name: team; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.team (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    deleted_at timestamp with time zone,
    name text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    photo_id uuid,
    features text[]
);
ALTER TABLE ONLY public.team ALTER COLUMN name SET STORAGE EXTERNAL;



--
-- Name: team_access_request; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.team_access_request (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    team_id uuid NOT NULL,
    requester_id uuid,
    valid_until timestamp with time zone NOT NULL,
    auto_join_until timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);



--
-- Name: team_font_variant; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.team_font_variant (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    team_id uuid NOT NULL,
    profile_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    font_id uuid NOT NULL,
    font_family text NOT NULL,
    font_weight smallint NOT NULL,
    font_style text NOT NULL,
    otf_file_id uuid,
    ttf_file_id uuid,
    woff1_file_id uuid,
    woff2_file_id uuid,
    variant_name text
);
ALTER TABLE ONLY public.team_font_variant ALTER COLUMN font_family SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.team_font_variant ALTER COLUMN font_style SET STORAGE EXTERNAL;



--
-- Name: team_invitation; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.team_invitation (
    team_id uuid,
    email_to text NOT NULL,
    role text NOT NULL,
    valid_until timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_by uuid,
    org_id uuid,
    CONSTRAINT team_invitation_team_or_org_not_null CHECK (((team_id IS NOT NULL) OR (org_id IS NOT NULL)))
);
ALTER TABLE ONLY public.team_invitation ALTER COLUMN email_to SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.team_invitation ALTER COLUMN role SET STORAGE EXTERNAL;



--
-- Name: team_profile_rel; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.team_profile_rel (
    team_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    is_admin boolean DEFAULT false,
    is_owner boolean DEFAULT false,
    can_edit boolean DEFAULT false,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL
);



--
-- Name: TABLE team_profile_rel; Type: COMMENT; Schema: public; Owner: penpot
--

COMMENT ON TABLE public.team_profile_rel IS 'Relation between teams and profiles (NM)';


--
-- Name: team_project_profile_rel; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.team_project_profile_rel (
    team_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    project_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    modified_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    is_pinned boolean DEFAULT false NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL
);



--
-- Name: upload_session; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.upload_session (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    profile_id uuid NOT NULL,
    total_chunks integer NOT NULL
);



--
-- Name: usage_quote; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.usage_quote (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    target text NOT NULL,
    quote bigint NOT NULL,
    profile_id uuid,
    project_id uuid,
    team_id uuid,
    file_id uuid
);
ALTER TABLE ONLY public.usage_quote ALTER COLUMN target SET STORAGE EXTERNAL;



--
-- Name: webhook; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.webhook (
    id uuid NOT NULL,
    team_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    uri text NOT NULL,
    mtype text NOT NULL,
    error_code text,
    error_count smallint DEFAULT 0,
    is_active boolean DEFAULT true,
    secret_key text,
    profile_id uuid
);
ALTER TABLE ONLY public.webhook ALTER COLUMN uri SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.webhook ALTER COLUMN mtype SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.webhook ALTER COLUMN error_code SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.webhook ALTER COLUMN secret_key SET STORAGE EXTERNAL;



--
-- Name: webhook_delivery; Type: TABLE; Schema: public; Owner: penpot
--

CREATE TABLE public.webhook_delivery (
    webhook_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    error_code text,
    req_data jsonb,
    rsp_data jsonb
);
ALTER TABLE ONLY public.webhook_delivery ALTER COLUMN error_code SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.webhook_delivery ALTER COLUMN req_data SET STORAGE EXTERNAL;
ALTER TABLE ONLY public.webhook_delivery ALTER COLUMN rsp_data SET STORAGE EXTERNAL;



--
-- Name: file_data_00; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_00 FOR VALUES WITH (modulus 16, remainder 0);


--
-- Name: file_data_01; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_01 FOR VALUES WITH (modulus 16, remainder 1);


--
-- Name: file_data_02; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_02 FOR VALUES WITH (modulus 16, remainder 2);


--
-- Name: file_data_03; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_03 FOR VALUES WITH (modulus 16, remainder 3);


--
-- Name: file_data_04; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_04 FOR VALUES WITH (modulus 16, remainder 4);


--
-- Name: file_data_05; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_05 FOR VALUES WITH (modulus 16, remainder 5);


--
-- Name: file_data_06; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_06 FOR VALUES WITH (modulus 16, remainder 6);


--
-- Name: file_data_07; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_07 FOR VALUES WITH (modulus 16, remainder 7);


--
-- Name: file_data_08; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_08 FOR VALUES WITH (modulus 16, remainder 8);


--
-- Name: file_data_09; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_09 FOR VALUES WITH (modulus 16, remainder 9);


--
-- Name: file_data_10; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_10 FOR VALUES WITH (modulus 16, remainder 10);


--
-- Name: file_data_11; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_11 FOR VALUES WITH (modulus 16, remainder 11);


--
-- Name: file_data_12; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_12 FOR VALUES WITH (modulus 16, remainder 12);


--
-- Name: file_data_13; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_13 FOR VALUES WITH (modulus 16, remainder 13);


--
-- Name: file_data_14; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_14 FOR VALUES WITH (modulus 16, remainder 14);


--
-- Name: file_data_15; Type: TABLE ATTACH; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data ATTACH PARTITION public.file_data_15 FOR VALUES WITH (modulus 16, remainder 15);


--
-- Name: access_token access_token_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.access_token
    ADD CONSTRAINT access_token_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: comment_thread comment_thread_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.comment_thread
    ADD CONSTRAINT comment_thread_pkey PRIMARY KEY (id);


--
-- Name: comment_thread_status comment_thread_status_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.comment_thread_status
    ADD CONSTRAINT comment_thread_status_pkey PRIMARY KEY (thread_id, profile_id);


--
-- Name: file_change file_change_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_change
    ADD CONSTRAINT file_change_pkey PRIMARY KEY (id);


--
-- Name: file_data file_data_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data
    ADD CONSTRAINT file_data_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_00 file_data_00_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_00
    ADD CONSTRAINT file_data_00_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_01 file_data_01_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_01
    ADD CONSTRAINT file_data_01_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_02 file_data_02_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_02
    ADD CONSTRAINT file_data_02_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_03 file_data_03_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_03
    ADD CONSTRAINT file_data_03_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_04 file_data_04_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_04
    ADD CONSTRAINT file_data_04_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_05 file_data_05_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_05
    ADD CONSTRAINT file_data_05_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_06 file_data_06_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_06
    ADD CONSTRAINT file_data_06_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_07 file_data_07_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_07
    ADD CONSTRAINT file_data_07_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_08 file_data_08_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_08
    ADD CONSTRAINT file_data_08_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_09 file_data_09_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_09
    ADD CONSTRAINT file_data_09_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_10 file_data_10_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_10
    ADD CONSTRAINT file_data_10_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_11 file_data_11_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_11
    ADD CONSTRAINT file_data_11_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_12 file_data_12_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_12
    ADD CONSTRAINT file_data_12_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_13 file_data_13_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_13
    ADD CONSTRAINT file_data_13_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_14 file_data_14_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_14
    ADD CONSTRAINT file_data_14_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_15 file_data_15_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_15
    ADD CONSTRAINT file_data_15_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_data_fragment file_data_fragment_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_fragment
    ADD CONSTRAINT file_data_fragment_pkey PRIMARY KEY (file_id, id);


--
-- Name: file_library_rel file_library_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_library_rel
    ADD CONSTRAINT file_library_rel_pkey PRIMARY KEY (file_id, library_file_id);


--
-- Name: file_library_sync file_library_sync_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_library_sync
    ADD CONSTRAINT file_library_sync_pkey PRIMARY KEY (file_id, library_file_id);


--
-- Name: file_media_object file_media_object_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_media_object
    ADD CONSTRAINT file_media_object_pkey PRIMARY KEY (id);


--
-- Name: file_migration file_migration_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_migration
    ADD CONSTRAINT file_migration_pkey PRIMARY KEY (file_id, name);


--
-- Name: file_object_thumbnail file_object_thumbnail_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_object_thumbnail
    ADD CONSTRAINT file_object_thumbnail_pkey PRIMARY KEY (file_id, object_id);


--
-- Name: file file_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file
    ADD CONSTRAINT file_pkey PRIMARY KEY (id);


--
-- Name: file_profile_rel file_profile_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_profile_rel
    ADD CONSTRAINT file_profile_rel_pkey PRIMARY KEY (file_id, profile_id);


--
-- Name: file_tagged_object_thumbnail file_tagged_object_thumbnail_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_tagged_object_thumbnail
    ADD CONSTRAINT file_tagged_object_thumbnail_pkey PRIMARY KEY (file_id, tag, object_id);


--
-- Name: file_thumbnail file_thumbnail_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_thumbnail
    ADD CONSTRAINT file_thumbnail_pkey PRIMARY KEY (file_id, revn);


--
-- Name: global_complaint_report global_complaint_report_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.global_complaint_report
    ADD CONSTRAINT global_complaint_report_pkey PRIMARY KEY (email, created_at);


--
-- Name: http_session http_session_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.http_session
    ADD CONSTRAINT http_session_pkey PRIMARY KEY (id);


--
-- Name: http_session_v2 http_session_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.http_session_v2
    ADD CONSTRAINT http_session_v2_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_module_step_key; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_module_step_key UNIQUE (module, step);


--
-- Name: presence presence_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.presence
    ADD CONSTRAINT presence_pkey PRIMARY KEY (file_id, session_id, profile_id);


--
-- Name: profile_complaint_report profile_complaint_report_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.profile_complaint_report
    ADD CONSTRAINT profile_complaint_report_pkey PRIMARY KEY (profile_id, created_at);


--
-- Name: profile profile_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (id);


--
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- Name: project_profile_rel project_profile_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.project_profile_rel
    ADD CONSTRAINT project_profile_rel_pkey PRIMARY KEY (id);


--
-- Name: project_profile_rel project_profile_rel_unique; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.project_profile_rel
    ADD CONSTRAINT project_profile_rel_unique UNIQUE (project_id, profile_id);


--
-- Name: scheduled_task_history scheduled_task_history_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.scheduled_task_history
    ADD CONSTRAINT scheduled_task_history_pkey PRIMARY KEY (id, created_at);


--
-- Name: scheduled_task scheduled_task_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.scheduled_task
    ADD CONSTRAINT scheduled_task_pkey PRIMARY KEY (id);


--
-- Name: server_error_report server_error_report_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.server_error_report
    ADD CONSTRAINT server_error_report_pkey PRIMARY KEY (id);


--
-- Name: server_prop server_prop_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.server_prop
    ADD CONSTRAINT server_prop_pkey PRIMARY KEY (id);


--
-- Name: share_link share_link_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.share_link
    ADD CONSTRAINT share_link_pkey PRIMARY KEY (id);


--
-- Name: sso_provider sso_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.sso_provider
    ADD CONSTRAINT sso_provider_pkey PRIMARY KEY (id);


--
-- Name: storage_object storage_object_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.storage_object
    ADD CONSTRAINT storage_object_pkey PRIMARY KEY (id);


--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- Name: team_access_request team_access_request_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_access_request
    ADD CONSTRAINT team_access_request_pkey PRIMARY KEY (id);


--
-- Name: team_access_request team_access_request_team_id_requester_id_key; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_access_request
    ADD CONSTRAINT team_access_request_team_id_requester_id_key UNIQUE (team_id, requester_id);


--
-- Name: team_font_variant team_font_variant_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_font_variant
    ADD CONSTRAINT team_font_variant_pkey PRIMARY KEY (id);


--
-- Name: team_invitation team_invitation_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_invitation
    ADD CONSTRAINT team_invitation_pkey PRIMARY KEY (id);


--
-- Name: team_invitation team_invitation_unique; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_invitation
    ADD CONSTRAINT team_invitation_unique UNIQUE (team_id, email_to);


--
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (id);


--
-- Name: team_profile_rel team_profile_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_profile_rel
    ADD CONSTRAINT team_profile_rel_pkey PRIMARY KEY (id);


--
-- Name: team_profile_rel team_profile_rel_unique; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_profile_rel
    ADD CONSTRAINT team_profile_rel_unique UNIQUE (team_id, profile_id);


--
-- Name: team_project_profile_rel team_project_profile_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_project_profile_rel
    ADD CONSTRAINT team_project_profile_rel_pkey PRIMARY KEY (id);


--
-- Name: team_project_profile_rel team_project_profile_rel_unique; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_project_profile_rel
    ADD CONSTRAINT team_project_profile_rel_unique UNIQUE (team_id, project_id, profile_id);


--
-- Name: upload_session upload_session_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.upload_session
    ADD CONSTRAINT upload_session_pkey PRIMARY KEY (id);


--
-- Name: usage_quote usage_quote_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.usage_quote
    ADD CONSTRAINT usage_quote_pkey PRIMARY KEY (id);


--
-- Name: webhook_delivery webhook_delivery_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.webhook_delivery
    ADD CONSTRAINT webhook_delivery_pkey PRIMARY KEY (webhook_id, created_at);


--
-- Name: webhook webhook_pkey; Type: CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.webhook
    ADD CONSTRAINT webhook_pkey PRIMARY KEY (id);


--
-- Name: access_token__profile_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX access_token__profile_id__idx ON public.access_token USING btree (profile_id);


--
-- Name: audit_log__archived_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX audit_log__archived_at__idx ON public.audit_log USING btree (archived_at) WHERE (archived_at IS NOT NULL);


--
-- Name: audit_log__created_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX audit_log__created_at__idx ON public.audit_log USING btree (created_at) WHERE (archived_at IS NULL);


--
-- Name: audit_log__source__created_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX audit_log__source__created_at__idx ON public.audit_log USING btree (source, created_at);


--
-- Name: comment__owner_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX comment__owner_id__idx ON public.comment USING btree (owner_id);


--
-- Name: comment__thread_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX comment__thread_id__idx ON public.comment USING btree (thread_id);


--
-- Name: comment_thread__file_id__seqn__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE UNIQUE INDEX comment_thread__file_id__seqn__idx ON public.comment_thread USING btree (file_id, seqn);


--
-- Name: comment_thread__owner_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX comment_thread__owner_id__idx ON public.comment_thread USING btree (owner_id);


--
-- Name: file__data_ref_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file__data_ref_id__idx ON public.file USING btree (data_ref_id);


--
-- Name: file__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file__deleted_at__idx ON public.file USING btree (deleted_at, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file__modified_at__has_media_trimmed__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file__modified_at__has_media_trimmed__idx ON public.file USING btree (modified_at) WHERE (has_media_trimmed IS FALSE);


--
-- Name: file__modified_at__with__data__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file__modified_at__with__data__idx ON public.file USING btree (modified_at, id) WHERE (data IS NOT NULL);


--
-- Name: file__project_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file__project_id__idx ON public.file USING btree (project_id);


--
-- Name: file_change__data_ref_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_change__data_ref_id__idx ON public.file_change USING btree (data_ref_id);


--
-- Name: file_change__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_change__deleted_at__idx ON public.file_change USING btree (deleted_at, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_change__file_id__revn__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_change__file_id__revn__idx ON public.file_change USING btree (file_id, revn);


--
-- Name: file_change__locked_by__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_change__locked_by__idx ON public.file_change USING btree (locked_by) WHERE (locked_by IS NOT NULL);


--
-- Name: file_change__profile_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_change__profile_id__idx ON public.file_change USING btree (profile_id) WHERE (profile_id IS NOT NULL);


--
-- Name: file_change__system_snapshots__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_change__system_snapshots__idx ON public.file_change USING btree (file_id, created_at) WHERE ((data IS NOT NULL) AND (created_by = 'system'::text) AND (deleted_at IS NULL));


--
-- Name: file_data__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data__deleted_at__idx ON ONLY public.file_data USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_00_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_00_deleted_at_file_id_id_idx ON public.file_data_00 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_01_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_01_deleted_at_file_id_id_idx ON public.file_data_01 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_02_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_02_deleted_at_file_id_id_idx ON public.file_data_02 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_03_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_03_deleted_at_file_id_id_idx ON public.file_data_03 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_04_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_04_deleted_at_file_id_id_idx ON public.file_data_04 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_05_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_05_deleted_at_file_id_id_idx ON public.file_data_05 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_06_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_06_deleted_at_file_id_id_idx ON public.file_data_06 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_07_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_07_deleted_at_file_id_id_idx ON public.file_data_07 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_08_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_08_deleted_at_file_id_id_idx ON public.file_data_08 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_09_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_09_deleted_at_file_id_id_idx ON public.file_data_09 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_10_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_10_deleted_at_file_id_id_idx ON public.file_data_10 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_11_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_11_deleted_at_file_id_id_idx ON public.file_data_11 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_12_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_12_deleted_at_file_id_id_idx ON public.file_data_12 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_13_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_13_deleted_at_file_id_id_idx ON public.file_data_13 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_14_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_14_deleted_at_file_id_id_idx ON public.file_data_14 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_15_deleted_at_file_id_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_15_deleted_at_file_id_id_idx ON public.file_data_15 USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_data_fragment__data_ref_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_fragment__data_ref_id__idx ON public.file_data_fragment USING btree (data_ref_id);


--
-- Name: file_data_fragment__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_data_fragment__deleted_at__idx ON public.file_data_fragment USING btree (deleted_at, file_id, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_library_rel__file_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_library_rel__file_id__idx ON public.file_library_rel USING btree (file_id);


--
-- Name: file_library_rel__library_file_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_library_rel__library_file_id__idx ON public.file_library_rel USING btree (library_file_id);


--
-- Name: file_media_object__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_media_object__deleted_at__idx ON public.file_media_object USING btree (deleted_at, id, media_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_media_object__file_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_media_object__file_id__idx ON public.file_media_object USING btree (file_id);


--
-- Name: file_media_object__image_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_media_object__image_id__idx ON public.file_media_object USING btree (media_id);


--
-- Name: file_media_object__thumbnail_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_media_object__thumbnail_id__idx ON public.file_media_object USING btree (thumbnail_id);


--
-- Name: file_profile_rel__file_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_profile_rel__file_id__idx ON public.file_profile_rel USING btree (file_id);


--
-- Name: file_profile_rel__profile_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_profile_rel__profile_id__idx ON public.file_profile_rel USING btree (profile_id);


--
-- Name: file_tagged_object_thumbnail__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_tagged_object_thumbnail__deleted_at__idx ON public.file_tagged_object_thumbnail USING btree (deleted_at, file_id, object_id, media_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_tagged_object_thumbnail__media_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_tagged_object_thumbnail__media_id__idx ON public.file_tagged_object_thumbnail USING btree (media_id);


--
-- Name: file_tagged_object_thumbnail__object_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_tagged_object_thumbnail__object_id__idx ON public.file_tagged_object_thumbnail USING btree (object_id);


--
-- Name: file_thumbnail__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_thumbnail__deleted_at__idx ON public.file_thumbnail USING btree (deleted_at, file_id, revn, media_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: file_thumbnail__media_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX file_thumbnail__media_id__idx ON public.file_thumbnail USING btree (media_id);


--
-- Name: http_session__updated_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX http_session__updated_at__idx ON public.http_session USING btree (updated_at) WHERE (updated_at IS NOT NULL);


--
-- Name: http_session_v2__profile_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX http_session_v2__profile_id__idx ON public.http_session_v2 USING btree (profile_id);


--
-- Name: http_session_v2__sso_provider_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX http_session_v2__sso_provider_id__idx ON public.http_session_v2 USING btree (sso_provider_id) WHERE (sso_provider_id IS NOT NULL);


--
-- Name: http_session_v2__sso_session_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX http_session_v2__sso_session_id__idx ON public.http_session_v2 USING btree (sso_session_id) WHERE (sso_session_id IS NOT NULL);


--
-- Name: profile__default_project__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX profile__default_project__idx ON public.profile USING btree (default_project_id);


--
-- Name: profile__default_team__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX profile__default_team__idx ON public.profile USING btree (default_team_id);


--
-- Name: profile__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX profile__deleted_at__idx ON public.profile USING btree (deleted_at, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: profile__email__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE UNIQUE INDEX profile__email__idx ON public.profile USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: profile__is_demo; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX profile__is_demo ON public.profile USING btree (is_demo) WHERE ((deleted_at IS NULL) AND (is_demo IS TRUE));


--
-- Name: profile__photo_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX profile__photo_id__idx ON public.profile USING btree (photo_id);


--
-- Name: profile__props__newsletter1__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX profile__props__newsletter1__idx ON public.profile USING btree (email) WHERE ((props ->> '~:newsletter-news'::text) = 'true'::text);


--
-- Name: profile__props__newsletter2__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX profile__props__newsletter2__idx ON public.profile USING btree (email) WHERE ((props ->> '~:newsletter-updates'::text) = 'true'::text);


--
-- Name: project__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX project__deleted_at__idx ON public.project USING btree (deleted_at, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: project__team_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX project__team_id__idx ON public.project USING btree (team_id);


--
-- Name: scheduled_task_history__task_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX scheduled_task_history__task_id__idx ON public.scheduled_task_history USING btree (task_id);


--
-- Name: server_error_report__created_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX server_error_report__created_at__idx ON public.server_error_report USING btree (created_at);


--
-- Name: server_error_report__version__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX server_error_report__version__idx ON public.server_error_report USING btree (version);


--
-- Name: share_link_file_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX share_link_file_id_idx ON public.share_link USING btree (file_id);


--
-- Name: share_link_owner_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX share_link_owner_id_idx ON public.share_link USING btree (owner_id);


--
-- Name: sso_provider__domain__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE UNIQUE INDEX sso_provider__domain__idx ON public.sso_provider USING btree (domain);


--
-- Name: storage_object__hash_backend_bucket__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX storage_object__hash_backend_bucket__idx ON public.storage_object USING btree (((metadata ->> '~:hash'::text)), ((metadata ->> '~:bucket'::text)), backend) WHERE (deleted_at IS NULL);


--
-- Name: storage_object__id__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX storage_object__id__deleted_at__idx ON public.storage_object USING btree (deleted_at, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: storage_object__id_touched_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX storage_object__id_touched_at__idx ON public.storage_object USING btree (touched_at, id) WHERE (touched_at IS NOT NULL);


--
-- Name: storage_object__metadata_upload_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX storage_object__metadata_upload_id__idx ON public.storage_object USING btree (((metadata ->> '~:upload-id'::text))) WHERE (deleted_at IS NULL);


--
-- Name: task__label_name_queue__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX task__label_name_queue__idx ON public.task USING btree (label, name, queue) WHERE (status = 'new'::text);


--
-- Name: task__scheduled_at_queue__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX task__scheduled_at_queue__idx ON public.task USING btree (scheduled_at, queue) WHERE ((status = 'new'::text) OR (status = 'retry'::text));


--
-- Name: team__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX team__deleted_at__idx ON public.team USING btree (deleted_at, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: team__photo_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX team__photo_id__idx ON public.team USING btree (photo_id);


--
-- Name: team_font_variant__deleted_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX team_font_variant__deleted_at__idx ON public.team_font_variant USING btree (deleted_at, id) WHERE (deleted_at IS NOT NULL);


--
-- Name: team_font_variant_otf_file_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX team_font_variant_otf_file_id_idx ON public.team_font_variant USING btree (otf_file_id);


--
-- Name: team_font_variant_profile_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX team_font_variant_profile_id_idx ON public.team_font_variant USING btree (profile_id);


--
-- Name: team_font_variant_team_id_font_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX team_font_variant_team_id_font_id_idx ON public.team_font_variant USING btree (team_id, font_id);


--
-- Name: team_font_variant_ttf_file_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX team_font_variant_ttf_file_id_idx ON public.team_font_variant USING btree (ttf_file_id);


--
-- Name: team_font_variant_woff1_file_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX team_font_variant_woff1_file_id_idx ON public.team_font_variant USING btree (woff1_file_id);


--
-- Name: team_font_variant_woff2_file_id_idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX team_font_variant_woff2_file_id_idx ON public.team_font_variant USING btree (woff2_file_id);


--
-- Name: team_invitation_org_unique; Type: INDEX; Schema: public; Owner: penpot
--

CREATE UNIQUE INDEX team_invitation_org_unique ON public.team_invitation USING btree (org_id, email_to) WHERE (team_id IS NULL);


--
-- Name: upload_session__created_at__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX upload_session__created_at__idx ON public.upload_session USING btree (created_at);


--
-- Name: upload_session__profile_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX upload_session__profile_id__idx ON public.upload_session USING btree (profile_id);


--
-- Name: usage_quote__profile_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX usage_quote__profile_id__idx ON public.usage_quote USING btree (profile_id, target);


--
-- Name: usage_quote__project_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX usage_quote__project_id__idx ON public.usage_quote USING btree (project_id, target);


--
-- Name: usage_quote__team_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX usage_quote__team_id__idx ON public.usage_quote USING btree (team_id, target);


--
-- Name: webhook__profile_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX webhook__profile_id__idx ON public.webhook USING btree (profile_id) WHERE (profile_id IS NOT NULL);


--
-- Name: webhook__team_id__idx; Type: INDEX; Schema: public; Owner: penpot
--

CREATE INDEX webhook__team_id__idx ON public.webhook USING btree (team_id);


--
-- Name: file_data_00_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_00_deleted_at_file_id_id_idx;


--
-- Name: file_data_00_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_00_pkey;


--
-- Name: file_data_01_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_01_deleted_at_file_id_id_idx;


--
-- Name: file_data_01_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_01_pkey;


--
-- Name: file_data_02_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_02_deleted_at_file_id_id_idx;


--
-- Name: file_data_02_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_02_pkey;


--
-- Name: file_data_03_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_03_deleted_at_file_id_id_idx;


--
-- Name: file_data_03_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_03_pkey;


--
-- Name: file_data_04_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_04_deleted_at_file_id_id_idx;


--
-- Name: file_data_04_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_04_pkey;


--
-- Name: file_data_05_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_05_deleted_at_file_id_id_idx;


--
-- Name: file_data_05_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_05_pkey;


--
-- Name: file_data_06_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_06_deleted_at_file_id_id_idx;


--
-- Name: file_data_06_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_06_pkey;


--
-- Name: file_data_07_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_07_deleted_at_file_id_id_idx;


--
-- Name: file_data_07_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_07_pkey;


--
-- Name: file_data_08_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_08_deleted_at_file_id_id_idx;


--
-- Name: file_data_08_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_08_pkey;


--
-- Name: file_data_09_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_09_deleted_at_file_id_id_idx;


--
-- Name: file_data_09_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_09_pkey;


--
-- Name: file_data_10_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_10_deleted_at_file_id_id_idx;


--
-- Name: file_data_10_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_10_pkey;


--
-- Name: file_data_11_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_11_deleted_at_file_id_id_idx;


--
-- Name: file_data_11_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_11_pkey;


--
-- Name: file_data_12_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_12_deleted_at_file_id_id_idx;


--
-- Name: file_data_12_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_12_pkey;


--
-- Name: file_data_13_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_13_deleted_at_file_id_id_idx;


--
-- Name: file_data_13_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_13_pkey;


--
-- Name: file_data_14_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_14_deleted_at_file_id_id_idx;


--
-- Name: file_data_14_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_14_pkey;


--
-- Name: file_data_15_deleted_at_file_id_id_idx; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data__deleted_at__idx ATTACH PARTITION public.file_data_15_deleted_at_file_id_id_idx;


--
-- Name: file_data_15_pkey; Type: INDEX ATTACH; Schema: public; Owner: penpot
--

ALTER INDEX public.file_data_pkey ATTACH PARTITION public.file_data_15_pkey;


--
-- Name: file_media_object deletion_protection__tgr; Type: TRIGGER; Schema: public; Owner: penpot
--

CREATE TRIGGER deletion_protection__tgr BEFORE DELETE ON public.file_media_object FOR EACH STATEMENT WHEN (((current_setting('rules.deletion_protection'::text, true) = ANY (ARRAY['on'::text, ''::text])) OR (current_setting('rules.deletion_protection'::text, true) IS NULL))) EXECUTE FUNCTION public.raise_deletion_protection();


--
-- Name: file_tagged_object_thumbnail deletion_protection__tgr; Type: TRIGGER; Schema: public; Owner: penpot
--

CREATE TRIGGER deletion_protection__tgr BEFORE DELETE ON public.file_tagged_object_thumbnail FOR EACH STATEMENT WHEN (((current_setting('rules.deletion_protection'::text, true) = ANY (ARRAY['on'::text, ''::text])) OR (current_setting('rules.deletion_protection'::text, true) IS NULL))) EXECUTE FUNCTION public.raise_deletion_protection();


--
-- Name: file_thumbnail deletion_protection__tgr; Type: TRIGGER; Schema: public; Owner: penpot
--

CREATE TRIGGER deletion_protection__tgr BEFORE DELETE ON public.file_thumbnail FOR EACH STATEMENT WHEN (((current_setting('rules.deletion_protection'::text, true) = ANY (ARRAY['on'::text, ''::text])) OR (current_setting('rules.deletion_protection'::text, true) IS NULL))) EXECUTE FUNCTION public.raise_deletion_protection();


--
-- Name: profile deletion_protection__tgr; Type: TRIGGER; Schema: public; Owner: penpot
--

CREATE TRIGGER deletion_protection__tgr BEFORE DELETE ON public.profile FOR EACH STATEMENT WHEN (((current_setting('rules.deletion_protection'::text, true) = ANY (ARRAY['on'::text, ''::text])) OR (current_setting('rules.deletion_protection'::text, true) IS NULL))) EXECUTE FUNCTION public.raise_deletion_protection();


--
-- Name: team deletion_protection__tgr; Type: TRIGGER; Schema: public; Owner: penpot
--

CREATE TRIGGER deletion_protection__tgr BEFORE DELETE ON public.team FOR EACH STATEMENT WHEN (((current_setting('rules.deletion_protection'::text, true) = ANY (ARRAY['on'::text, ''::text])) OR (current_setting('rules.deletion_protection'::text, true) IS NULL))) EXECUTE FUNCTION public.raise_deletion_protection();


--
-- Name: team_font_variant deletion_protection__tgr; Type: TRIGGER; Schema: public; Owner: penpot
--

CREATE TRIGGER deletion_protection__tgr BEFORE DELETE ON public.team_font_variant FOR EACH STATEMENT WHEN (((current_setting('rules.deletion_protection'::text, true) = ANY (ARRAY['on'::text, ''::text])) OR (current_setting('rules.deletion_protection'::text, true) IS NULL))) EXECUTE FUNCTION public.raise_deletion_protection();


--
-- Name: access_token access_token_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.access_token
    ADD CONSTRAINT access_token_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: comment comment_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: comment_thread comment_thread_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.comment_thread
    ADD CONSTRAINT comment_thread_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) ON DELETE CASCADE;


--
-- Name: comment comment_thread_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.comment_thread(id) ON DELETE CASCADE;


--
-- Name: comment_thread comment_thread_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.comment_thread
    ADD CONSTRAINT comment_thread_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: comment_thread_status comment_thread_status_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.comment_thread_status
    ADD CONSTRAINT comment_thread_status_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: comment_thread_status comment_thread_status_thread_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.comment_thread_status
    ADD CONSTRAINT comment_thread_status_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.comment_thread(id) ON DELETE CASCADE;


--
-- Name: file_change file_change_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_change
    ADD CONSTRAINT file_change_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) DEFERRABLE;


--
-- Name: file_change file_change_locked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_change
    ADD CONSTRAINT file_change_locked_by_fkey FOREIGN KEY (locked_by) REFERENCES public.profile(id) ON DELETE SET NULL DEFERRABLE;


--
-- Name: file_change file_change_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_change
    ADD CONSTRAINT file_change_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE SET NULL DEFERRABLE;


--
-- Name: file_data file_data_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE public.file_data
    ADD CONSTRAINT file_data_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) DEFERRABLE;


--
-- Name: file_data_fragment file_data_fragment_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_data_fragment
    ADD CONSTRAINT file_data_fragment_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: file_library_rel file_library_rel_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_library_rel
    ADD CONSTRAINT file_library_rel_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: file_library_rel file_library_rel_library_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_library_rel
    ADD CONSTRAINT file_library_rel_library_file_id_fkey FOREIGN KEY (library_file_id) REFERENCES public.file(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: file_media_object file_media_object_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_media_object
    ADD CONSTRAINT file_media_object_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) DEFERRABLE;


--
-- Name: file_media_object file_media_object_media_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_media_object
    ADD CONSTRAINT file_media_object_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.storage_object(id) DEFERRABLE;


--
-- Name: file_media_object file_media_object_thumbnail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_media_object
    ADD CONSTRAINT file_media_object_thumbnail_id_fkey FOREIGN KEY (thumbnail_id) REFERENCES public.storage_object(id) DEFERRABLE;


--
-- Name: file_migration file_migration_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_migration
    ADD CONSTRAINT file_migration_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: file_object_thumbnail file_object_thumbnail_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_object_thumbnail
    ADD CONSTRAINT file_object_thumbnail_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) DEFERRABLE;


--
-- Name: file_object_thumbnail file_object_thumbnail_media_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_object_thumbnail
    ADD CONSTRAINT file_object_thumbnail_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.storage_object(id) DEFERRABLE;


--
-- Name: file_profile_rel file_profile_rel_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_profile_rel
    ADD CONSTRAINT file_profile_rel_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) ON DELETE CASCADE;


--
-- Name: file_profile_rel file_profile_rel_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_profile_rel
    ADD CONSTRAINT file_profile_rel_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: file file_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file
    ADD CONSTRAINT file_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id) DEFERRABLE;


--
-- Name: file_tagged_object_thumbnail file_tagged_object_thumbnail_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_tagged_object_thumbnail
    ADD CONSTRAINT file_tagged_object_thumbnail_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) DEFERRABLE;


--
-- Name: file_tagged_object_thumbnail file_tagged_object_thumbnail_media_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_tagged_object_thumbnail
    ADD CONSTRAINT file_tagged_object_thumbnail_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.storage_object(id) DEFERRABLE;


--
-- Name: file_thumbnail file_thumbnail_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_thumbnail
    ADD CONSTRAINT file_thumbnail_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) DEFERRABLE;


--
-- Name: file_thumbnail file_thumbnail_media_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.file_thumbnail
    ADD CONSTRAINT file_thumbnail_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.storage_object(id) DEFERRABLE;


--
-- Name: http_session http_session_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.http_session
    ADD CONSTRAINT http_session_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: http_session_v2 http_session_v2_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.http_session_v2
    ADD CONSTRAINT http_session_v2_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: http_session_v2 http_session_v2_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.http_session_v2
    ADD CONSTRAINT http_session_v2_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES public.sso_provider(id) ON DELETE CASCADE;


--
-- Name: presence presence_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.presence
    ADD CONSTRAINT presence_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) ON DELETE CASCADE;


--
-- Name: presence presence_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.presence
    ADD CONSTRAINT presence_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: profile_complaint_report profile_complaint_report_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.profile_complaint_report
    ADD CONSTRAINT profile_complaint_report_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: profile profile_default_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT profile_default_project_id_fkey FOREIGN KEY (default_project_id) REFERENCES public.project(id) DEFERRABLE;


--
-- Name: profile profile_default_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT profile_default_team_id_fkey FOREIGN KEY (default_team_id) REFERENCES public.team(id) DEFERRABLE;


--
-- Name: profile profile_photo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT profile_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES public.storage_object(id) DEFERRABLE;


--
-- Name: project_profile_rel project_profile_rel_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.project_profile_rel
    ADD CONSTRAINT project_profile_rel_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: project_profile_rel project_profile_rel_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.project_profile_rel
    ADD CONSTRAINT project_profile_rel_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: project project_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(id) DEFERRABLE;


--
-- Name: scheduled_task_history scheduled_task_history_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.scheduled_task_history
    ADD CONSTRAINT scheduled_task_history_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.scheduled_task(id);


--
-- Name: share_link share_link_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.share_link
    ADD CONSTRAINT share_link_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: share_link share_link_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.share_link
    ADD CONSTRAINT share_link_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profile(id) ON DELETE SET NULL DEFERRABLE;


--
-- Name: team_access_request team_access_request_requester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_access_request
    ADD CONSTRAINT team_access_request_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.profile(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: team_access_request team_access_request_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_access_request
    ADD CONSTRAINT team_access_request_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: team_font_variant team_font_variant_otf_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_font_variant
    ADD CONSTRAINT team_font_variant_otf_file_id_fkey FOREIGN KEY (otf_file_id) REFERENCES public.storage_object(id) DEFERRABLE;


--
-- Name: team_font_variant team_font_variant_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_font_variant
    ADD CONSTRAINT team_font_variant_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE SET NULL DEFERRABLE;


--
-- Name: team_font_variant team_font_variant_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_font_variant
    ADD CONSTRAINT team_font_variant_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(id) DEFERRABLE;


--
-- Name: team_font_variant team_font_variant_ttf_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_font_variant
    ADD CONSTRAINT team_font_variant_ttf_file_id_fkey FOREIGN KEY (ttf_file_id) REFERENCES public.storage_object(id) DEFERRABLE;


--
-- Name: team_font_variant team_font_variant_woff1_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_font_variant
    ADD CONSTRAINT team_font_variant_woff1_file_id_fkey FOREIGN KEY (woff1_file_id) REFERENCES public.storage_object(id) DEFERRABLE;


--
-- Name: team_font_variant team_font_variant_woff2_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_font_variant
    ADD CONSTRAINT team_font_variant_woff2_file_id_fkey FOREIGN KEY (woff2_file_id) REFERENCES public.storage_object(id) DEFERRABLE;


--
-- Name: team_invitation team_invitation_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_invitation
    ADD CONSTRAINT team_invitation_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profile(id) ON DELETE SET NULL;


--
-- Name: team_invitation team_invitation_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_invitation
    ADD CONSTRAINT team_invitation_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(id) ON DELETE CASCADE;


--
-- Name: team team_photo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES public.storage_object(id) DEFERRABLE;


--
-- Name: team_profile_rel team_profile_rel_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_profile_rel
    ADD CONSTRAINT team_profile_rel_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: team_profile_rel team_profile_rel_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_profile_rel
    ADD CONSTRAINT team_profile_rel_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(id) ON DELETE CASCADE;


--
-- Name: team_project_profile_rel team_project_profile_rel_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_project_profile_rel
    ADD CONSTRAINT team_project_profile_rel_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: team_project_profile_rel team_project_profile_rel_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_project_profile_rel
    ADD CONSTRAINT team_project_profile_rel_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: team_project_profile_rel team_project_profile_rel_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.team_project_profile_rel
    ADD CONSTRAINT team_project_profile_rel_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(id) ON DELETE CASCADE;


--
-- Name: upload_session upload_session_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.upload_session
    ADD CONSTRAINT upload_session_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE;


--
-- Name: usage_quote usage_quote_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.usage_quote
    ADD CONSTRAINT usage_quote_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: usage_quote usage_quote_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.usage_quote
    ADD CONSTRAINT usage_quote_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: usage_quote usage_quote_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.usage_quote
    ADD CONSTRAINT usage_quote_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: usage_quote usage_quote_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.usage_quote
    ADD CONSTRAINT usage_quote_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: webhook_delivery webhook_delivery_webhook_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.webhook_delivery
    ADD CONSTRAINT webhook_delivery_webhook_id_fkey FOREIGN KEY (webhook_id) REFERENCES public.webhook(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: webhook webhook_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.webhook
    ADD CONSTRAINT webhook_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profile(id) ON DELETE SET NULL;


--
-- Name: webhook webhook_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: penpot
--

ALTER TABLE ONLY public.webhook
    ADD CONSTRAINT webhook_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(id) ON DELETE CASCADE DEFERRABLE;


--
-- PostgreSQL database dump complete
--


