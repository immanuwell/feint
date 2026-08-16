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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_job_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_job_locks (
    id integer NOT NULL,
    lock_key character varying,
    active_job_id character varying,
    created_at timestamp(3) without time zone,
    updated_at timestamp(3) without time zone
);


--
-- Name: active_job_locks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_job_locks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_job_locks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_job_locks_id_seq OWNED BY public.active_job_locks.id;


--
-- Name: activity_streams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_streams (
    id integer NOT NULL,
    activity_stream_type_id integer NOT NULL,
    activity_stream_object_id integer NOT NULL,
    permission_id integer,
    group_id integer,
    o_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: activity_streams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_streams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_streams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_streams_id_seq OWNED BY public.activity_streams.id;


--
-- Name: ai_agents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_agents (
    id integer NOT NULL,
    name character varying(250) DEFAULT ''::character varying NOT NULL,
    definition jsonb DEFAULT '{}'::jsonb NOT NULL,
    action_definition jsonb DEFAULT '{}'::jsonb NOT NULL,
    agent_type character varying(250),
    type_enrichment_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    note character varying(250),
    active boolean DEFAULT true NOT NULL,
    created_by_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ai_agents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_agents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_agents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_agents_id_seq OWNED BY public.ai_agents.id;


--
-- Name: ai_analytics_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_analytics_runs (
    id integer NOT NULL,
    identifier character varying NOT NULL,
    version character varying,
    ai_service_name character varying NOT NULL,
    locale_id integer,
    related_object_type character varying,
    related_object_id integer,
    triggered_by_type character varying,
    triggered_by_id integer,
    regeneration_of_id integer,
    content jsonb DEFAULT '{}'::jsonb NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    context jsonb DEFAULT '{}'::jsonb NOT NULL,
    error jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(3) without time zone,
    updated_at timestamp(3) without time zone
);


--
-- Name: ai_analytics_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_analytics_runs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_analytics_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_analytics_runs_id_seq OWNED BY public.ai_analytics_runs.id;


--
-- Name: ai_analytics_usages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_analytics_usages (
    id integer NOT NULL,
    ai_analytics_run_id integer NOT NULL,
    user_id integer NOT NULL,
    rating boolean,
    comment text,
    context jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(3) without time zone,
    updated_at timestamp(3) without time zone
);


--
-- Name: ai_analytics_usages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_analytics_usages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_analytics_usages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_analytics_usages_id_seq OWNED BY public.ai_analytics_usages.id;


--
-- Name: ai_stored_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_stored_results (
    id integer NOT NULL,
    identifier character varying NOT NULL,
    version character varying,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    content jsonb DEFAULT '{}'::jsonb NOT NULL,
    locale_id integer,
    related_object_type character varying,
    related_object_id integer,
    ai_analytics_run_id integer,
    created_at timestamp(3) without time zone,
    updated_at timestamp(3) without time zone
);


--
-- Name: ai_stored_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_stored_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_stored_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_stored_results_id_seq OWNED BY public.ai_stored_results.id;


--
-- Name: ai_text_tools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_text_tools (
    id integer NOT NULL,
    name character varying(250) DEFAULT ''::character varying NOT NULL,
    instruction character varying(1048576) DEFAULT ''::character varying NOT NULL,
    note character varying(250),
    active boolean DEFAULT true NOT NULL,
    created_by_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    analytics_stats_reset_at timestamp(3) without time zone
);


--
-- Name: ai_text_tools_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_text_tools_groups (
    text_tool_id integer,
    group_id integer
);


--
-- Name: ai_text_tools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_text_tools_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_text_tools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_text_tools_id_seq OWNED BY public.ai_text_tools.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: authorizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authorizations (
    id integer NOT NULL,
    provider character varying(250) NOT NULL,
    uid character varying(250) NOT NULL,
    token character varying(2500),
    secret character varying(250),
    username character varying(250),
    user_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: authorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authorizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authorizations_id_seq OWNED BY public.authorizations.id;


--
-- Name: avatars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.avatars (
    id integer NOT NULL,
    o_id integer NOT NULL,
    object_lookup_id integer NOT NULL,
    "default" boolean DEFAULT false NOT NULL,
    deletable boolean DEFAULT true NOT NULL,
    initial boolean DEFAULT false NOT NULL,
    store_full_id integer,
    store_resize_id integer,
    store_hash character varying(32),
    source character varying(100) NOT NULL,
    source_url character varying(512),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: avatars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.avatars_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: avatars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.avatars_id_seq OWNED BY public.avatars.id;


--
-- Name: calendars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calendars (
    id integer NOT NULL,
    name character varying(250),
    timezone character varying(250),
    business_hours character varying(3000),
    "default" boolean DEFAULT false NOT NULL,
    ical_url character varying(500),
    public_holidays text,
    last_log text,
    last_sync timestamp(3) without time zone,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: calendars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.calendars_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: calendars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.calendars_id_seq OWNED BY public.calendars.id;


--
-- Name: channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channels (
    id integer NOT NULL,
    group_id integer,
    area character varying(100) NOT NULL,
    options text,
    active boolean DEFAULT true NOT NULL,
    preferences character varying(2000),
    last_log_in text,
    last_log_out text,
    status_in character varying(100),
    status_out character varying(100),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: channels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.channels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.channels_id_seq OWNED BY public.channels.id;


--
-- Name: chat_agents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_agents (
    id integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    concurrent integer DEFAULT 5 NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: chat_agents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chat_agents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chat_agents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chat_agents_id_seq OWNED BY public.chat_agents.id;


--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_messages (
    id integer NOT NULL,
    chat_session_id integer NOT NULL,
    content text NOT NULL,
    created_by_id integer,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chat_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chat_messages_id_seq OWNED BY public.chat_messages.id;


--
-- Name: chat_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_sessions (
    id integer NOT NULL,
    chat_id integer NOT NULL,
    session_id character varying NOT NULL,
    name character varying(250),
    state character varying(50) DEFAULT 'waiting'::character varying NOT NULL,
    user_id integer,
    preferences text,
    updated_by_id integer,
    created_by_id integer,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: chat_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chat_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chat_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chat_sessions_id_seq OWNED BY public.chat_sessions.id;


--
-- Name: chats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chats (
    id integer NOT NULL,
    name character varying(250),
    max_queue integer DEFAULT 5 NOT NULL,
    note character varying(250),
    active boolean DEFAULT true NOT NULL,
    public boolean DEFAULT false NOT NULL,
    block_ip character varying(5000),
    block_country character varying(5000),
    allowed_websites character varying(5000),
    preferences character varying(5000),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: chats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chats_id_seq OWNED BY public.chats.id;


--
-- Name: checklist_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checklist_items (
    id integer NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    checked boolean DEFAULT false NOT NULL,
    checklist_id integer NOT NULL,
    created_by_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    ticket_id integer,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: checklist_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checklist_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklist_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checklist_items_id_seq OWNED BY public.checklist_items.id;


--
-- Name: checklist_template_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checklist_template_items (
    id integer NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    checklist_template_id integer NOT NULL,
    created_by_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: checklist_template_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checklist_template_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklist_template_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checklist_template_items_id_seq OWNED BY public.checklist_template_items.id;


--
-- Name: checklist_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checklist_templates (
    id integer NOT NULL,
    name character varying(250) DEFAULT ''::character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    sorted_item_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    created_by_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: checklist_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checklist_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklist_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checklist_templates_id_seq OWNED BY public.checklist_templates.id;


--
-- Name: checklists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checklists (
    id integer NOT NULL,
    name character varying(250) DEFAULT ''::character varying NOT NULL,
    sorted_item_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    created_by_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: checklists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checklists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checklists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checklists_id_seq OWNED BY public.checklists.id;


--
-- Name: core_workflows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_workflows (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    object character varying(100),
    preferences text,
    condition_saved text,
    condition_selected text,
    perform text,
    active boolean DEFAULT true NOT NULL,
    stop_after_match boolean DEFAULT false NOT NULL,
    changeable boolean DEFAULT true NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: core_workflows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.core_workflows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: core_workflows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.core_workflows_id_seq OWNED BY public.core_workflows.id;


--
-- Name: cti_caller_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cti_caller_ids (
    id integer NOT NULL,
    caller_id character varying(100) NOT NULL,
    comment character varying(500),
    level character varying(100) NOT NULL,
    object character varying(100) NOT NULL,
    o_id integer NOT NULL,
    user_id integer,
    preferences text,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: cti_caller_ids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cti_caller_ids_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cti_caller_ids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cti_caller_ids_id_seq OWNED BY public.cti_caller_ids.id;


--
-- Name: cti_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cti_logs (
    id integer NOT NULL,
    direction character varying(20) NOT NULL,
    state character varying(20) NOT NULL,
    "from" character varying(100) NOT NULL,
    from_comment character varying(250),
    "to" character varying(100) NOT NULL,
    to_comment character varying(250),
    queue character varying(250),
    call_id character varying(250) NOT NULL,
    comment character varying(500),
    initialized_at timestamp(3) without time zone,
    start_at timestamp(3) without time zone,
    end_at timestamp(3) without time zone,
    duration_waiting_time integer,
    duration_talking_time integer,
    done boolean DEFAULT true NOT NULL,
    preferences text,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: cti_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cti_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cti_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cti_logs_id_seq OWNED BY public.cti_logs.id;


--
-- Name: data_privacy_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_privacy_tasks (
    id integer NOT NULL,
    state character varying(150) DEFAULT 'in process'::character varying,
    deletable_type character varying,
    deletable_id integer,
    preferences text,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: data_privacy_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.data_privacy_tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_privacy_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_privacy_tasks_id_seq OWNED BY public.data_privacy_tasks.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp(3) without time zone,
    locked_at timestamp(3) without time zone,
    failed_at timestamp(3) without time zone,
    locked_by character varying,
    queue character varying,
    active_job_id character varying,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: email_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_addresses (
    id integer NOT NULL,
    channel_id integer,
    name character varying(250) NOT NULL,
    email character varying(255) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    note character varying(250),
    preferences character varying(2000),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: email_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_addresses_id_seq OWNED BY public.email_addresses.id;


--
-- Name: external_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_credentials (
    id integer NOT NULL,
    name character varying,
    credentials character varying(2500) NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: external_credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_credentials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_credentials_id_seq OWNED BY public.external_credentials.id;


--
-- Name: external_syncs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_syncs (
    id integer NOT NULL,
    source character varying(100) NOT NULL,
    source_id character varying(200) NOT NULL,
    object character varying(100) NOT NULL,
    o_id integer NOT NULL,
    last_payload text,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: external_syncs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_syncs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_syncs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_syncs_id_seq OWNED BY public.external_syncs.id;


--
-- Name: failed_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_emails (
    id integer NOT NULL,
    data bytea NOT NULL,
    retries integer DEFAULT 1 NOT NULL,
    parsing_error text
);


--
-- Name: failed_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.failed_emails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failed_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.failed_emails_id_seq OWNED BY public.failed_emails.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    signature_id integer,
    email_address_id integer,
    name character varying(1618) NOT NULL,
    name_last character varying(160) NOT NULL,
    parent_id integer,
    assignment_timeout integer,
    follow_up_possible character varying(100) DEFAULT 'yes'::character varying NOT NULL,
    reopen_time_in_days integer,
    follow_up_assignment boolean DEFAULT true NOT NULL,
    active boolean DEFAULT true NOT NULL,
    shared_drafts boolean DEFAULT true NOT NULL,
    summary_generation character varying DEFAULT 'global_default'::character varying NOT NULL,
    note character varying(250),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: groups_macros; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups_macros (
    macro_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: groups_text_modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups_text_modules (
    text_module_id integer,
    group_id integer
);


--
-- Name: groups_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups_users (
    user_id integer NOT NULL,
    group_id integer NOT NULL,
    access character varying(50) DEFAULT 'full'::character varying NOT NULL
);


--
-- Name: histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.histories (
    id integer NOT NULL,
    history_type_id integer NOT NULL,
    history_object_id integer NOT NULL,
    history_attribute_id integer,
    sourceable_type character varying,
    sourceable_id integer,
    sourceable_name character varying(500),
    o_id integer NOT NULL,
    related_o_id integer,
    related_history_object_id integer,
    id_to integer,
    id_from integer,
    value_from character varying(500),
    value_to character varying(500),
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.histories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.histories_id_seq OWNED BY public.histories.id;


--
-- Name: history_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.history_attributes (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: history_attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.history_attributes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.history_attributes_id_seq OWNED BY public.history_attributes.id;


--
-- Name: history_objects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.history_objects (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    note character varying(250),
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: history_objects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.history_objects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_objects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.history_objects_id_seq OWNED BY public.history_objects.id;


--
-- Name: history_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.history_types (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: history_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.history_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.history_types_id_seq OWNED BY public.history_types.id;


--
-- Name: http_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.http_logs (
    id integer NOT NULL,
    direction character varying(20) NOT NULL,
    facility character varying(100) NOT NULL,
    method character varying(100) NOT NULL,
    url text NOT NULL,
    status character varying(20),
    ip character varying(50),
    request text NOT NULL,
    response text NOT NULL,
    updated_by_id integer,
    created_by_id integer,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: http_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.http_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: http_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.http_logs_id_seq OWNED BY public.http_logs.id;


--
-- Name: import_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_jobs (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    dry_run boolean DEFAULT false NOT NULL,
    payload text,
    result text,
    started_at timestamp(3) without time zone,
    finished_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: import_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.import_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.import_jobs_id_seq OWNED BY public.import_jobs.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    timeplan character varying(2500) NOT NULL,
    object character varying(100) NOT NULL,
    condition text NOT NULL,
    perform text NOT NULL,
    disable_notification boolean DEFAULT true NOT NULL,
    last_run_at timestamp(3) without time zone,
    next_run_at timestamp(3) without time zone,
    running boolean DEFAULT false NOT NULL,
    processed integer DEFAULT 0 NOT NULL,
    matching integer NOT NULL,
    pid character varying(250),
    localization character varying(20),
    timezone character varying(250),
    note character varying(250),
    active boolean DEFAULT false NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: knowledge_base_answer_translation_contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_base_answer_translation_contents (
    id integer NOT NULL,
    body text
);


--
-- Name: knowledge_base_answer_translation_contents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_base_answer_translation_contents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_answer_translation_contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_base_answer_translation_contents_id_seq OWNED BY public.knowledge_base_answer_translation_contents.id;


--
-- Name: knowledge_base_answer_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_base_answer_translations (
    id integer NOT NULL,
    title character varying(250) NOT NULL,
    kb_locale_id integer NOT NULL,
    answer_id integer NOT NULL,
    content_id integer NOT NULL,
    created_by_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: knowledge_base_answer_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_base_answer_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_answer_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_base_answer_translations_id_seq OWNED BY public.knowledge_base_answer_translations.id;


--
-- Name: knowledge_base_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_base_answers (
    id integer NOT NULL,
    category_id integer NOT NULL,
    promoted boolean DEFAULT false NOT NULL,
    internal_note text,
    "position" integer NOT NULL,
    archived_at timestamp(3) without time zone,
    archived_by_id integer,
    internal_at timestamp(3) without time zone,
    internal_by_id integer,
    published_at timestamp(3) without time zone,
    published_by_id integer,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: knowledge_base_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_base_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_base_answers_id_seq OWNED BY public.knowledge_base_answers.id;


--
-- Name: knowledge_base_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_base_categories (
    id integer NOT NULL,
    knowledge_base_id integer NOT NULL,
    parent_id integer,
    category_icon character varying(30) NOT NULL,
    "position" integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: knowledge_base_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_base_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_base_categories_id_seq OWNED BY public.knowledge_base_categories.id;


--
-- Name: knowledge_base_category_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_base_category_translations (
    id integer NOT NULL,
    title character varying(250) NOT NULL,
    kb_locale_id integer NOT NULL,
    category_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: knowledge_base_category_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_base_category_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_category_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_base_category_translations_id_seq OWNED BY public.knowledge_base_category_translations.id;


--
-- Name: knowledge_base_locales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_base_locales (
    id integer NOT NULL,
    knowledge_base_id integer NOT NULL,
    system_locale_id integer NOT NULL,
    "primary" boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: knowledge_base_locales_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_base_locales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_locales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_base_locales_id_seq OWNED BY public.knowledge_base_locales.id;


--
-- Name: knowledge_base_menu_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_base_menu_items (
    id integer NOT NULL,
    kb_locale_id integer NOT NULL,
    location character varying NOT NULL,
    "position" integer NOT NULL,
    title character varying(100) NOT NULL,
    url character varying(500) NOT NULL,
    new_tab boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: knowledge_base_menu_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_base_menu_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_menu_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_base_menu_items_id_seq OWNED BY public.knowledge_base_menu_items.id;


--
-- Name: knowledge_base_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_base_permissions (
    id integer NOT NULL,
    permissionable_type character varying NOT NULL,
    permissionable_id integer NOT NULL,
    role_id integer NOT NULL,
    access character varying(50) DEFAULT 'full'::character varying NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: knowledge_base_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_base_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_base_permissions_id_seq OWNED BY public.knowledge_base_permissions.id;


--
-- Name: knowledge_base_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_base_translations (
    id integer NOT NULL,
    title character varying(250) NOT NULL,
    footer_note character varying NOT NULL,
    kb_locale_id integer NOT NULL,
    knowledge_base_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: knowledge_base_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_base_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_base_translations_id_seq OWNED BY public.knowledge_base_translations.id;


--
-- Name: knowledge_bases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_bases (
    id integer NOT NULL,
    iconset character varying(30) NOT NULL,
    color_highlight character varying(25) NOT NULL,
    color_header character varying(25) NOT NULL,
    color_header_link character varying(25) NOT NULL,
    homepage_layout character varying NOT NULL,
    category_layout character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    show_feed_icon boolean DEFAULT false NOT NULL,
    custom_address character varying,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: knowledge_bases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_bases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_bases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_bases_id_seq OWNED BY public.knowledge_bases.id;


--
-- Name: ldap_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ldap_sources (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    preferences text,
    prio integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ldap_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ldap_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ldap_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ldap_sources_id_seq OWNED BY public.ldap_sources.id;


--
-- Name: link_objects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.link_objects (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    note character varying(250),
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: link_objects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.link_objects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_objects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.link_objects_id_seq OWNED BY public.link_objects.id;


--
-- Name: link_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.link_types (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    note character varying(250),
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: link_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.link_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.link_types_id_seq OWNED BY public.link_types.id;


--
-- Name: links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.links (
    id integer NOT NULL,
    link_type_id integer NOT NULL,
    link_object_source_id integer NOT NULL,
    link_object_source_value integer NOT NULL,
    link_object_target_id integer NOT NULL,
    link_object_target_value integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.links_id_seq OWNED BY public.links.id;


--
-- Name: locales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locales (
    id integer NOT NULL,
    locale character varying(20) NOT NULL,
    alias character varying(20),
    name character varying(255) NOT NULL,
    dir character varying(9) DEFAULT 'ltr'::character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: locales_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locales_id_seq OWNED BY public.locales.id;


--
-- Name: macros; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.macros (
    id integer NOT NULL,
    name character varying(250),
    perform text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    ux_flow_next_up character varying DEFAULT 'none'::character varying NOT NULL,
    note character varying(250),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: macros_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.macros_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: macros_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.macros_id_seq OWNED BY public.macros.id;


--
-- Name: mentions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mentions (
    id integer NOT NULL,
    mentionable_type character varying NOT NULL,
    mentionable_id integer NOT NULL,
    user_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mentions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mentions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mentions_id_seq OWNED BY public.mentions.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id integer NOT NULL,
    resource_owner_id integer NOT NULL,
    application_id integer NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id integer NOT NULL,
    resource_owner_id integer,
    application_id integer,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id integer NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    confidential boolean DEFAULT true NOT NULL
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_applications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: object_lookups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.object_lookups (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: object_lookups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.object_lookups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: object_lookups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.object_lookups_id_seq OWNED BY public.object_lookups.id;


--
-- Name: object_manager_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.object_manager_attributes (
    id integer NOT NULL,
    object_lookup_id integer NOT NULL,
    name character varying(200) NOT NULL,
    display character varying(200) NOT NULL,
    data_type character varying(100) NOT NULL,
    data_option text,
    data_option_new text,
    editable boolean DEFAULT true NOT NULL,
    internal boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    screens character varying(2000),
    to_create boolean DEFAULT false NOT NULL,
    to_migrate boolean DEFAULT false NOT NULL,
    to_delete boolean DEFAULT false NOT NULL,
    to_config boolean DEFAULT false NOT NULL,
    "position" integer NOT NULL,
    created_by_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: object_manager_attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.object_manager_attributes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: object_manager_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.object_manager_attributes_id_seq OWNED BY public.object_manager_attributes.id;


--
-- Name: online_notification_standalones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.online_notification_standalones (
    id integer NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    kind character varying NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: online_notification_standalones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.online_notification_standalones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: online_notification_standalones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.online_notification_standalones_id_seq OWNED BY public.online_notification_standalones.id;


--
-- Name: online_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.online_notifications (
    id integer NOT NULL,
    o_id integer NOT NULL,
    object_lookup_id integer NOT NULL,
    type_lookup_id integer NOT NULL,
    user_id integer NOT NULL,
    seen boolean DEFAULT false NOT NULL,
    meta jsonb DEFAULT '{}'::jsonb NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: online_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.online_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: online_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.online_notifications_id_seq OWNED BY public.online_notifications.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    shared boolean DEFAULT true NOT NULL,
    domain character varying(250) DEFAULT ''::character varying,
    domain_assignment boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    vip boolean DEFAULT false NOT NULL,
    note character varying(5000) DEFAULT ''::character varying,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: organizations_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_users (
    user_id integer,
    organization_id integer
);


--
-- Name: overviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.overviews (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    link character varying(250) NOT NULL,
    prio integer NOT NULL,
    condition text NOT NULL,
    "order" character varying(2500) NOT NULL,
    group_by character varying(250),
    group_direction character varying(250),
    organization_shared boolean DEFAULT false NOT NULL,
    out_of_office boolean DEFAULT false NOT NULL,
    view character varying(1000) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: overviews_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.overviews_groups (
    overview_id integer,
    group_id integer
);


--
-- Name: overviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.overviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: overviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.overviews_id_seq OWNED BY public.overviews.id;


--
-- Name: overviews_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.overviews_roles (
    overview_id integer,
    role_id integer
);


--
-- Name: overviews_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.overviews_users (
    overview_id integer,
    user_id integer
);


--
-- Name: package_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.package_migrations (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    version character varying(250) NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: package_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.package_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: package_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.package_migrations_id_seq OWNED BY public.package_migrations.id;


--
-- Name: packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.packages (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    version character varying(50) NOT NULL,
    vendor character varying(150) NOT NULL,
    state character varying(50) NOT NULL,
    url character varying(512),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: packages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.packages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.packages_id_seq OWNED BY public.packages.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    label character varying(255),
    description character varying(500),
    preferences character varying(10000),
    active boolean DEFAULT true NOT NULL,
    allow_signup boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: permissions_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions_roles (
    role_id integer,
    permission_id integer
);


--
-- Name: pgp_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pgp_keys (
    id integer NOT NULL,
    name character varying(3000) NOT NULL,
    fingerprint character varying(40) NOT NULL,
    key text NOT NULL,
    expires_at timestamp(3) without time zone,
    email_addresses character varying[],
    secret boolean DEFAULT false NOT NULL,
    passphrase character varying(500),
    domain_alias character varying(255) DEFAULT ''::character varying,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: pgp_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pgp_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pgp_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pgp_keys_id_seq OWNED BY public.pgp_keys.id;


--
-- Name: postmaster_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postmaster_filters (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    channel character varying(250) NOT NULL,
    match text NOT NULL,
    perform text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    note character varying(250),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: postmaster_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.postmaster_filters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: postmaster_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.postmaster_filters_id_seq OWNED BY public.postmaster_filters.id;


--
-- Name: public_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_links (
    id integer NOT NULL,
    link character varying(500) NOT NULL,
    title character varying(200) NOT NULL,
    description character varying(200),
    screen character varying[] NOT NULL,
    new_tab boolean DEFAULT true NOT NULL,
    prio integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: public_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.public_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: public_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.public_links_id_seq OWNED BY public.public_links.id;


--
-- Name: recent_closes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recent_closes (
    id integer NOT NULL,
    recently_closed_object_type character varying NOT NULL,
    recently_closed_object_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp(3) without time zone,
    updated_at timestamp(3) without time zone
);


--
-- Name: recent_closes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recent_closes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recent_closes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recent_closes_id_seq OWNED BY public.recent_closes.id;


--
-- Name: recent_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recent_views (
    id integer NOT NULL,
    recent_view_object_id integer NOT NULL,
    o_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: recent_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recent_views_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recent_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recent_views_id_seq OWNED BY public.recent_views.id;


--
-- Name: report_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_profiles (
    id integer NOT NULL,
    name character varying(150),
    condition text,
    active boolean DEFAULT true NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: report_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.report_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.report_profiles_id_seq OWNED BY public.report_profiles.id;


--
-- Name: report_profiles_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_profiles_roles (
    profile_id integer NOT NULL,
    role_id integer NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    preferences text,
    default_at_signup boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    note character varying(250),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: roles_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles_groups (
    role_id integer NOT NULL,
    group_id integer NOT NULL,
    access character varying(50) DEFAULT 'full'::character varying NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: roles_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles_users (
    user_id integer,
    role_id integer
);


--
-- Name: schedulers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedulers (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    method character varying(250) NOT NULL,
    period integer,
    running integer DEFAULT 0 NOT NULL,
    last_run timestamp(3) without time zone,
    prio integer NOT NULL,
    pid character varying(250),
    note character varying(250),
    error_message character varying,
    status character varying,
    active boolean DEFAULT false NOT NULL,
    timeplan character varying(2500),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: schedulers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schedulers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schedulers_id_seq OWNED BY public.schedulers.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    session_id character varying NOT NULL,
    persistent boolean,
    data text,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id integer NOT NULL,
    title character varying(200) NOT NULL,
    name character varying(200) NOT NULL,
    area character varying(100) NOT NULL,
    description character varying(2000) NOT NULL,
    options text,
    state_current text,
    state_initial character varying(2000),
    frontend boolean DEFAULT false NOT NULL,
    preferences text,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: signatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.signatures (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    body text,
    active boolean DEFAULT true NOT NULL,
    note character varying(250),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: signatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.signatures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: signatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.signatures_id_seq OWNED BY public.signatures.id;


--
-- Name: slas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slas (
    id integer NOT NULL,
    calendar_id integer NOT NULL,
    name character varying(150),
    first_response_time integer,
    response_time integer,
    update_time integer,
    solution_time integer,
    condition text,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: slas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.slas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slas_id_seq OWNED BY public.slas.id;


--
-- Name: smime_certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.smime_certificates (
    id integer NOT NULL,
    fingerprint character varying(250) NOT NULL,
    uid character varying(1024) NOT NULL,
    email_addresses character varying[],
    pem bytea NOT NULL,
    private_key bytea,
    private_key_secret character varying(500),
    issuer_hash character varying(128),
    subject_hash character varying(128),
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: smime_certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.smime_certificates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: smime_certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.smime_certificates_id_seq OWNED BY public.smime_certificates.id;


--
-- Name: ssl_certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ssl_certificates (
    id integer NOT NULL,
    fingerprint character varying(250) NOT NULL,
    certificate bytea NOT NULL,
    subject character varying(250) NOT NULL,
    not_before timestamp(3) without time zone NOT NULL,
    not_after timestamp(3) without time zone NOT NULL,
    ca boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ssl_certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ssl_certificates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ssl_certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ssl_certificates_id_seq OWNED BY public.ssl_certificates.id;


--
-- Name: stats_stores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stats_stores (
    id integer NOT NULL,
    stats_storable_type character varying,
    stats_storable_id integer,
    key character varying(250),
    data character varying(5000),
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: stats_stores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stats_stores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stats_stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stats_stores_id_seq OWNED BY public.stats_stores.id;


--
-- Name: store_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.store_files (
    id integer NOT NULL,
    sha character varying(128) NOT NULL,
    provider character varying(20),
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: store_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.store_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: store_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.store_files_id_seq OWNED BY public.store_files.id;


--
-- Name: store_objects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.store_objects (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    note character varying(250),
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: store_objects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.store_objects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: store_objects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.store_objects_id_seq OWNED BY public.store_objects.id;


--
-- Name: store_provider_dbs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.store_provider_dbs (
    id integer NOT NULL,
    sha character varying(128) NOT NULL,
    data bytea,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: store_provider_dbs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.store_provider_dbs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: store_provider_dbs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.store_provider_dbs_id_seq OWNED BY public.store_provider_dbs.id;


--
-- Name: stores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stores (
    id integer NOT NULL,
    store_object_id integer NOT NULL,
    store_file_id integer NOT NULL,
    o_id character varying(255) NOT NULL,
    preferences character varying(2500),
    size character varying(50),
    filename character varying(250) NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: stores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stores_id_seq OWNED BY public.stores.id;


--
-- Name: system_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_reports (
    id integer NOT NULL,
    data text,
    uuid character varying(50) NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: system_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_reports_id_seq OWNED BY public.system_reports.id;


--
-- Name: tag_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_items (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    name_downcase character varying(250) NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: tag_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_items_id_seq OWNED BY public.tag_items.id;


--
-- Name: tag_objects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_objects (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: tag_objects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_objects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_objects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_objects_id_seq OWNED BY public.tag_objects.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    tag_item_id integer NOT NULL,
    tag_object_id integer NOT NULL,
    o_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: taskbars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taskbars (
    id integer NOT NULL,
    user_id integer NOT NULL,
    last_contact timestamp(3) without time zone NOT NULL,
    key character varying(100) NOT NULL,
    callback character varying(100) NOT NULL,
    state text,
    preferences text,
    params character varying(2000),
    prio integer NOT NULL,
    notify boolean DEFAULT false NOT NULL,
    active boolean DEFAULT false NOT NULL,
    app character varying DEFAULT 'desktop'::character varying NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: taskbars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taskbars_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taskbars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taskbars_id_seq OWNED BY public.taskbars.id;


--
-- Name: templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    options text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.templates_id_seq OWNED BY public.templates.id;


--
-- Name: text_modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.text_modules (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    keywords character varying(500),
    content text NOT NULL,
    note character varying(250),
    active boolean DEFAULT true NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: text_modules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.text_modules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: text_modules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.text_modules_id_seq OWNED BY public.text_modules.id;


--
-- Name: ticket_article_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_article_flags (
    id integer NOT NULL,
    ticket_article_id integer NOT NULL,
    key character varying(50) NOT NULL,
    value character varying(50),
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ticket_article_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_article_flags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_article_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_article_flags_id_seq OWNED BY public.ticket_article_flags.id;


--
-- Name: ticket_article_senders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_article_senders (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    note character varying(250),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ticket_article_senders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_article_senders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_article_senders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_article_senders_id_seq OWNED BY public.ticket_article_senders.id;


--
-- Name: ticket_article_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_article_types (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    note character varying(250),
    communication boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ticket_article_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_article_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_article_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_article_types_id_seq OWNED BY public.ticket_article_types.id;


--
-- Name: ticket_articles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_articles (
    id integer NOT NULL,
    ticket_id integer NOT NULL,
    type_id integer NOT NULL,
    sender_id integer NOT NULL,
    detected_language character varying(8),
    "from" character varying(3000),
    "to" character varying(3000),
    cc character varying(3000),
    subject character varying(3000),
    reply_to character varying(300),
    message_id character varying(3000),
    message_id_md5 character varying(32),
    in_reply_to character varying(3000),
    content_type character varying(20) DEFAULT 'text/plain'::character varying NOT NULL,
    body text NOT NULL,
    internal boolean DEFAULT false NOT NULL,
    preferences text,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    origin_by_id integer,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ticket_articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_articles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_articles_id_seq OWNED BY public.ticket_articles.id;


--
-- Name: ticket_counters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_counters (
    id integer NOT NULL,
    content character varying(100) NOT NULL,
    generator character varying(100) NOT NULL
);


--
-- Name: ticket_counters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_counters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_counters_id_seq OWNED BY public.ticket_counters.id;


--
-- Name: ticket_daily_event_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_daily_event_locks (
    id integer NOT NULL,
    date date NOT NULL,
    lock_type character varying NOT NULL,
    lock_activator character varying NOT NULL,
    ticket_id integer NOT NULL,
    related_object_type character varying,
    related_object_id integer,
    created_at timestamp(3) without time zone,
    updated_at timestamp(3) without time zone
);


--
-- Name: ticket_daily_event_locks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_daily_event_locks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_daily_event_locks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_daily_event_locks_id_seq OWNED BY public.ticket_daily_event_locks.id;


--
-- Name: ticket_priorities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_priorities (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    default_create boolean DEFAULT false NOT NULL,
    ui_icon character varying(100),
    ui_color character varying(100),
    note character varying(250),
    active boolean DEFAULT true NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ticket_priorities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_priorities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_priorities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_priorities_id_seq OWNED BY public.ticket_priorities.id;


--
-- Name: ticket_shared_draft_starts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_shared_draft_starts (
    id integer NOT NULL,
    group_id integer NOT NULL,
    name character varying,
    content text,
    created_by_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_at timestamp(3) without time zone,
    updated_at timestamp(3) without time zone
);


--
-- Name: ticket_shared_draft_starts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_shared_draft_starts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_shared_draft_starts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_shared_draft_starts_id_seq OWNED BY public.ticket_shared_draft_starts.id;


--
-- Name: ticket_shared_draft_zooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_shared_draft_zooms (
    id integer NOT NULL,
    ticket_id integer NOT NULL,
    new_article text,
    ticket_attributes text,
    created_by_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_at timestamp(3) without time zone,
    updated_at timestamp(3) without time zone
);


--
-- Name: ticket_shared_draft_zooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_shared_draft_zooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_shared_draft_zooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_shared_draft_zooms_id_seq OWNED BY public.ticket_shared_draft_zooms.id;


--
-- Name: ticket_state_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_state_types (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    note character varying(250),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ticket_state_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_state_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_state_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_state_types_id_seq OWNED BY public.ticket_state_types.id;


--
-- Name: ticket_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_states (
    id integer NOT NULL,
    state_type_id integer NOT NULL,
    name character varying(250) NOT NULL,
    next_state_id integer,
    ignore_escalation boolean DEFAULT false NOT NULL,
    default_create boolean DEFAULT false NOT NULL,
    default_follow_up boolean DEFAULT false NOT NULL,
    default_close boolean DEFAULT false NOT NULL,
    note character varying(250),
    active boolean DEFAULT true NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ticket_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_states_id_seq OWNED BY public.ticket_states.id;


--
-- Name: ticket_time_accounting_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_time_accounting_types (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    note character varying(250),
    active boolean DEFAULT true NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ticket_time_accounting_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_time_accounting_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_time_accounting_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_time_accounting_types_id_seq OWNED BY public.ticket_time_accounting_types.id;


--
-- Name: ticket_time_accountings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_time_accountings (
    id integer NOT NULL,
    ticket_id integer NOT NULL,
    ticket_article_id integer,
    time_unit numeric(6,2) NOT NULL,
    type_id integer,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ticket_time_accountings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_time_accountings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_time_accountings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_time_accountings_id_seq OWNED BY public.ticket_time_accountings.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    group_id integer NOT NULL,
    priority_id integer NOT NULL,
    state_id integer NOT NULL,
    organization_id integer,
    number character varying(60) NOT NULL,
    title character varying(250) NOT NULL,
    owner_id integer NOT NULL,
    customer_id integer NOT NULL,
    note character varying(250),
    first_response_at timestamp(3) without time zone,
    first_response_escalation_at timestamp(3) without time zone,
    first_response_in_min integer,
    first_response_diff_in_min integer,
    close_at timestamp(3) without time zone,
    close_escalation_at timestamp(3) without time zone,
    close_in_min integer,
    close_diff_in_min integer,
    update_escalation_at timestamp(3) without time zone,
    update_in_min integer,
    update_diff_in_min integer,
    last_close_at timestamp(3) without time zone,
    last_contact_at timestamp(3) without time zone,
    last_contact_agent_at timestamp(3) without time zone,
    last_contact_customer_at timestamp(3) without time zone,
    last_owner_update_at timestamp(3) without time zone,
    create_article_type_id integer,
    create_article_sender_id integer,
    article_count integer,
    escalation_at timestamp(3) without time zone,
    pending_time timestamp(3) without time zone,
    type character varying(100),
    time_unit numeric(6,2),
    preferences text,
    ai_agent_running boolean DEFAULT false NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    checklist_id integer
);


--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    persistent boolean DEFAULT false NOT NULL,
    name character varying(255),
    token character varying(100) NOT NULL,
    action character varying(40) NOT NULL,
    preferences text,
    last_used_at timestamp(3) without time zone,
    expires_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tokens_id_seq OWNED BY public.tokens.id;


--
-- Name: translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.translations (
    id integer NOT NULL,
    locale character varying(10) NOT NULL,
    source character varying(3000) NOT NULL,
    target character varying(3000) NOT NULL,
    target_initial character varying(3000) NOT NULL,
    is_synchronized_from_codebase boolean DEFAULT false NOT NULL,
    synchronized_from_translation_file character varying(255),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.translations_id_seq OWNED BY public.translations.id;


--
-- Name: triggers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.triggers (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    condition text NOT NULL,
    perform text NOT NULL,
    disable_notification boolean DEFAULT true NOT NULL,
    localization character varying(20),
    timezone character varying(250),
    note character varying(250),
    activator character varying(50) DEFAULT 'action'::character varying NOT NULL,
    execution_condition_mode character varying(50) DEFAULT 'selective'::character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.triggers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: triggers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.triggers_id_seq OWNED BY public.triggers.id;


--
-- Name: type_lookups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.type_lookups (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: type_lookups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.type_lookups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: type_lookups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.type_lookups_id_seq OWNED BY public.type_lookups.id;


--
-- Name: user_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_devices (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying(250) NOT NULL,
    os character varying(150),
    browser character varying(250),
    location character varying(150),
    device_details character varying(2500),
    location_details character varying(2500),
    fingerprint character varying(160),
    user_agent character varying(250),
    ip character varying(160),
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: user_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_devices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_devices_id_seq OWNED BY public.user_devices.id;


--
-- Name: user_overview_sortings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_overview_sortings (
    id integer NOT NULL,
    user_id integer NOT NULL,
    overview_id integer NOT NULL,
    prio integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: user_overview_sortings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_overview_sortings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_overview_sortings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_overview_sortings_id_seq OWNED BY public.user_overview_sortings.id;


--
-- Name: user_two_factor_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_two_factor_preferences (
    id integer NOT NULL,
    method character varying(100) NOT NULL,
    configuration text,
    user_id integer NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: user_two_factor_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_two_factor_preferences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_two_factor_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_two_factor_preferences_id_seq OWNED BY public.user_two_factor_preferences.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    organization_id integer,
    login character varying(255) NOT NULL,
    firstname character varying(100) DEFAULT ''::character varying,
    lastname character varying(100) DEFAULT ''::character varying,
    email character varying(255) DEFAULT ''::character varying,
    image character varying(100),
    image_source character varying(200),
    web character varying(100) DEFAULT ''::character varying,
    password character varying(100),
    phone character varying(100) DEFAULT ''::character varying,
    fax character varying(100) DEFAULT ''::character varying,
    mobile character varying(100) DEFAULT ''::character varying,
    department character varying(200) DEFAULT ''::character varying,
    street character varying(120) DEFAULT ''::character varying,
    zip character varying(100) DEFAULT ''::character varying,
    city character varying(100) DEFAULT ''::character varying,
    country character varying(100) DEFAULT ''::character varying,
    address character varying(500) DEFAULT ''::character varying,
    vip boolean DEFAULT false NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    note character varying(5000) DEFAULT ''::character varying,
    last_login timestamp(3) without time zone,
    source character varying(200),
    login_failed integer DEFAULT 0 NOT NULL,
    out_of_office boolean DEFAULT false NOT NULL,
    out_of_office_start_at date,
    out_of_office_end_at date,
    out_of_office_replacement_id integer,
    preferences character varying(8000),
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    endpoint character varying(2000) NOT NULL,
    http_method character varying(10) DEFAULT 'post'::character varying NOT NULL,
    signature_token character varying(200),
    ssl_verify boolean DEFAULT true NOT NULL,
    basic_auth_username character varying(250),
    basic_auth_password character varying(250),
    bearer_token character varying(2500),
    note character varying(500),
    pre_defined_webhook_type character varying(250),
    customized_payload boolean DEFAULT false NOT NULL,
    custom_payload text,
    preferences text,
    active boolean DEFAULT true NOT NULL,
    updated_by_id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_at timestamp(3) without time zone NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhooks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhooks_id_seq OWNED BY public.webhooks.id;


--
-- Name: active_job_locks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_job_locks ALTER COLUMN id SET DEFAULT nextval('public.active_job_locks_id_seq'::regclass);


--
-- Name: activity_streams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_streams ALTER COLUMN id SET DEFAULT nextval('public.activity_streams_id_seq'::regclass);


--
-- Name: ai_agents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agents ALTER COLUMN id SET DEFAULT nextval('public.ai_agents_id_seq'::regclass);


--
-- Name: ai_analytics_runs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_analytics_runs ALTER COLUMN id SET DEFAULT nextval('public.ai_analytics_runs_id_seq'::regclass);


--
-- Name: ai_analytics_usages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_analytics_usages ALTER COLUMN id SET DEFAULT nextval('public.ai_analytics_usages_id_seq'::regclass);


--
-- Name: ai_stored_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_stored_results ALTER COLUMN id SET DEFAULT nextval('public.ai_stored_results_id_seq'::regclass);


--
-- Name: ai_text_tools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_text_tools ALTER COLUMN id SET DEFAULT nextval('public.ai_text_tools_id_seq'::regclass);


--
-- Name: authorizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authorizations ALTER COLUMN id SET DEFAULT nextval('public.authorizations_id_seq'::regclass);


--
-- Name: avatars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avatars ALTER COLUMN id SET DEFAULT nextval('public.avatars_id_seq'::regclass);


--
-- Name: calendars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendars ALTER COLUMN id SET DEFAULT nextval('public.calendars_id_seq'::regclass);


--
-- Name: channels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels ALTER COLUMN id SET DEFAULT nextval('public.channels_id_seq'::regclass);


--
-- Name: chat_agents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_agents ALTER COLUMN id SET DEFAULT nextval('public.chat_agents_id_seq'::regclass);


--
-- Name: chat_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages ALTER COLUMN id SET DEFAULT nextval('public.chat_messages_id_seq'::regclass);


--
-- Name: chat_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_sessions ALTER COLUMN id SET DEFAULT nextval('public.chat_sessions_id_seq'::regclass);


--
-- Name: chats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chats ALTER COLUMN id SET DEFAULT nextval('public.chats_id_seq'::regclass);


--
-- Name: checklist_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_items ALTER COLUMN id SET DEFAULT nextval('public.checklist_items_id_seq'::regclass);


--
-- Name: checklist_template_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_template_items ALTER COLUMN id SET DEFAULT nextval('public.checklist_template_items_id_seq'::regclass);


--
-- Name: checklist_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_templates ALTER COLUMN id SET DEFAULT nextval('public.checklist_templates_id_seq'::regclass);


--
-- Name: checklists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklists ALTER COLUMN id SET DEFAULT nextval('public.checklists_id_seq'::regclass);


--
-- Name: core_workflows id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workflows ALTER COLUMN id SET DEFAULT nextval('public.core_workflows_id_seq'::regclass);


--
-- Name: cti_caller_ids id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cti_caller_ids ALTER COLUMN id SET DEFAULT nextval('public.cti_caller_ids_id_seq'::regclass);


--
-- Name: cti_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cti_logs ALTER COLUMN id SET DEFAULT nextval('public.cti_logs_id_seq'::regclass);


--
-- Name: data_privacy_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_privacy_tasks ALTER COLUMN id SET DEFAULT nextval('public.data_privacy_tasks_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: email_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses ALTER COLUMN id SET DEFAULT nextval('public.email_addresses_id_seq'::regclass);


--
-- Name: external_credentials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_credentials ALTER COLUMN id SET DEFAULT nextval('public.external_credentials_id_seq'::regclass);


--
-- Name: external_syncs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_syncs ALTER COLUMN id SET DEFAULT nextval('public.external_syncs_id_seq'::regclass);


--
-- Name: failed_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_emails ALTER COLUMN id SET DEFAULT nextval('public.failed_emails_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.histories ALTER COLUMN id SET DEFAULT nextval('public.histories_id_seq'::regclass);


--
-- Name: history_attributes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history_attributes ALTER COLUMN id SET DEFAULT nextval('public.history_attributes_id_seq'::regclass);


--
-- Name: history_objects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history_objects ALTER COLUMN id SET DEFAULT nextval('public.history_objects_id_seq'::regclass);


--
-- Name: history_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history_types ALTER COLUMN id SET DEFAULT nextval('public.history_types_id_seq'::regclass);


--
-- Name: http_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.http_logs ALTER COLUMN id SET DEFAULT nextval('public.http_logs_id_seq'::regclass);


--
-- Name: import_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_jobs ALTER COLUMN id SET DEFAULT nextval('public.import_jobs_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: knowledge_base_answer_translation_contents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answer_translation_contents ALTER COLUMN id SET DEFAULT nextval('public.knowledge_base_answer_translation_contents_id_seq'::regclass);


--
-- Name: knowledge_base_answer_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answer_translations ALTER COLUMN id SET DEFAULT nextval('public.knowledge_base_answer_translations_id_seq'::regclass);


--
-- Name: knowledge_base_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answers ALTER COLUMN id SET DEFAULT nextval('public.knowledge_base_answers_id_seq'::regclass);


--
-- Name: knowledge_base_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_categories ALTER COLUMN id SET DEFAULT nextval('public.knowledge_base_categories_id_seq'::regclass);


--
-- Name: knowledge_base_category_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_category_translations ALTER COLUMN id SET DEFAULT nextval('public.knowledge_base_category_translations_id_seq'::regclass);


--
-- Name: knowledge_base_locales id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_locales ALTER COLUMN id SET DEFAULT nextval('public.knowledge_base_locales_id_seq'::regclass);


--
-- Name: knowledge_base_menu_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_menu_items ALTER COLUMN id SET DEFAULT nextval('public.knowledge_base_menu_items_id_seq'::regclass);


--
-- Name: knowledge_base_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_permissions ALTER COLUMN id SET DEFAULT nextval('public.knowledge_base_permissions_id_seq'::regclass);


--
-- Name: knowledge_base_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_translations ALTER COLUMN id SET DEFAULT nextval('public.knowledge_base_translations_id_seq'::regclass);


--
-- Name: knowledge_bases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_bases ALTER COLUMN id SET DEFAULT nextval('public.knowledge_bases_id_seq'::regclass);


--
-- Name: ldap_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_sources ALTER COLUMN id SET DEFAULT nextval('public.ldap_sources_id_seq'::regclass);


--
-- Name: link_objects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_objects ALTER COLUMN id SET DEFAULT nextval('public.link_objects_id_seq'::regclass);


--
-- Name: link_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_types ALTER COLUMN id SET DEFAULT nextval('public.link_types_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links ALTER COLUMN id SET DEFAULT nextval('public.links_id_seq'::regclass);


--
-- Name: locales id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locales ALTER COLUMN id SET DEFAULT nextval('public.locales_id_seq'::regclass);


--
-- Name: macros id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.macros ALTER COLUMN id SET DEFAULT nextval('public.macros_id_seq'::regclass);


--
-- Name: mentions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions ALTER COLUMN id SET DEFAULT nextval('public.mentions_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: object_lookups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_lookups ALTER COLUMN id SET DEFAULT nextval('public.object_lookups_id_seq'::regclass);


--
-- Name: object_manager_attributes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_manager_attributes ALTER COLUMN id SET DEFAULT nextval('public.object_manager_attributes_id_seq'::regclass);


--
-- Name: online_notification_standalones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_notification_standalones ALTER COLUMN id SET DEFAULT nextval('public.online_notification_standalones_id_seq'::regclass);


--
-- Name: online_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_notifications ALTER COLUMN id SET DEFAULT nextval('public.online_notifications_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: overviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overviews ALTER COLUMN id SET DEFAULT nextval('public.overviews_id_seq'::regclass);


--
-- Name: package_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_migrations ALTER COLUMN id SET DEFAULT nextval('public.package_migrations_id_seq'::regclass);


--
-- Name: packages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages ALTER COLUMN id SET DEFAULT nextval('public.packages_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: pgp_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgp_keys ALTER COLUMN id SET DEFAULT nextval('public.pgp_keys_id_seq'::regclass);


--
-- Name: postmaster_filters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postmaster_filters ALTER COLUMN id SET DEFAULT nextval('public.postmaster_filters_id_seq'::regclass);


--
-- Name: public_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_links ALTER COLUMN id SET DEFAULT nextval('public.public_links_id_seq'::regclass);


--
-- Name: recent_closes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recent_closes ALTER COLUMN id SET DEFAULT nextval('public.recent_closes_id_seq'::regclass);


--
-- Name: recent_views id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recent_views ALTER COLUMN id SET DEFAULT nextval('public.recent_views_id_seq'::regclass);


--
-- Name: report_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_profiles ALTER COLUMN id SET DEFAULT nextval('public.report_profiles_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: schedulers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedulers ALTER COLUMN id SET DEFAULT nextval('public.schedulers_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: signatures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signatures ALTER COLUMN id SET DEFAULT nextval('public.signatures_id_seq'::regclass);


--
-- Name: slas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slas ALTER COLUMN id SET DEFAULT nextval('public.slas_id_seq'::regclass);


--
-- Name: smime_certificates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.smime_certificates ALTER COLUMN id SET DEFAULT nextval('public.smime_certificates_id_seq'::regclass);


--
-- Name: ssl_certificates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ssl_certificates ALTER COLUMN id SET DEFAULT nextval('public.ssl_certificates_id_seq'::regclass);


--
-- Name: stats_stores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stats_stores ALTER COLUMN id SET DEFAULT nextval('public.stats_stores_id_seq'::regclass);


--
-- Name: store_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_files ALTER COLUMN id SET DEFAULT nextval('public.store_files_id_seq'::regclass);


--
-- Name: store_objects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_objects ALTER COLUMN id SET DEFAULT nextval('public.store_objects_id_seq'::regclass);


--
-- Name: store_provider_dbs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_provider_dbs ALTER COLUMN id SET DEFAULT nextval('public.store_provider_dbs_id_seq'::regclass);


--
-- Name: stores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores ALTER COLUMN id SET DEFAULT nextval('public.stores_id_seq'::regclass);


--
-- Name: system_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_reports ALTER COLUMN id SET DEFAULT nextval('public.system_reports_id_seq'::regclass);


--
-- Name: tag_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_items ALTER COLUMN id SET DEFAULT nextval('public.tag_items_id_seq'::regclass);


--
-- Name: tag_objects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_objects ALTER COLUMN id SET DEFAULT nextval('public.tag_objects_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: taskbars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taskbars ALTER COLUMN id SET DEFAULT nextval('public.taskbars_id_seq'::regclass);


--
-- Name: templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates ALTER COLUMN id SET DEFAULT nextval('public.templates_id_seq'::regclass);


--
-- Name: text_modules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_modules ALTER COLUMN id SET DEFAULT nextval('public.text_modules_id_seq'::regclass);


--
-- Name: ticket_article_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_flags ALTER COLUMN id SET DEFAULT nextval('public.ticket_article_flags_id_seq'::regclass);


--
-- Name: ticket_article_senders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_senders ALTER COLUMN id SET DEFAULT nextval('public.ticket_article_senders_id_seq'::regclass);


--
-- Name: ticket_article_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_types ALTER COLUMN id SET DEFAULT nextval('public.ticket_article_types_id_seq'::regclass);


--
-- Name: ticket_articles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_articles ALTER COLUMN id SET DEFAULT nextval('public.ticket_articles_id_seq'::regclass);


--
-- Name: ticket_counters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_counters ALTER COLUMN id SET DEFAULT nextval('public.ticket_counters_id_seq'::regclass);


--
-- Name: ticket_daily_event_locks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_daily_event_locks ALTER COLUMN id SET DEFAULT nextval('public.ticket_daily_event_locks_id_seq'::regclass);


--
-- Name: ticket_priorities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_priorities ALTER COLUMN id SET DEFAULT nextval('public.ticket_priorities_id_seq'::regclass);


--
-- Name: ticket_shared_draft_starts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_shared_draft_starts ALTER COLUMN id SET DEFAULT nextval('public.ticket_shared_draft_starts_id_seq'::regclass);


--
-- Name: ticket_shared_draft_zooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_shared_draft_zooms ALTER COLUMN id SET DEFAULT nextval('public.ticket_shared_draft_zooms_id_seq'::regclass);


--
-- Name: ticket_state_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_state_types ALTER COLUMN id SET DEFAULT nextval('public.ticket_state_types_id_seq'::regclass);


--
-- Name: ticket_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_states ALTER COLUMN id SET DEFAULT nextval('public.ticket_states_id_seq'::regclass);


--
-- Name: ticket_time_accounting_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_time_accounting_types ALTER COLUMN id SET DEFAULT nextval('public.ticket_time_accounting_types_id_seq'::regclass);


--
-- Name: ticket_time_accountings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_time_accountings ALTER COLUMN id SET DEFAULT nextval('public.ticket_time_accountings_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens ALTER COLUMN id SET DEFAULT nextval('public.tokens_id_seq'::regclass);


--
-- Name: translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translations ALTER COLUMN id SET DEFAULT nextval('public.translations_id_seq'::regclass);


--
-- Name: triggers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.triggers ALTER COLUMN id SET DEFAULT nextval('public.triggers_id_seq'::regclass);


--
-- Name: type_lookups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.type_lookups ALTER COLUMN id SET DEFAULT nextval('public.type_lookups_id_seq'::regclass);


--
-- Name: user_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_devices ALTER COLUMN id SET DEFAULT nextval('public.user_devices_id_seq'::regclass);


--
-- Name: user_overview_sortings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_overview_sortings ALTER COLUMN id SET DEFAULT nextval('public.user_overview_sortings_id_seq'::regclass);


--
-- Name: user_two_factor_preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_two_factor_preferences ALTER COLUMN id SET DEFAULT nextval('public.user_two_factor_preferences_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: webhooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks ALTER COLUMN id SET DEFAULT nextval('public.webhooks_id_seq'::regclass);


--
-- Name: active_job_locks active_job_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_job_locks
    ADD CONSTRAINT active_job_locks_pkey PRIMARY KEY (id);


--
-- Name: activity_streams activity_streams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_streams
    ADD CONSTRAINT activity_streams_pkey PRIMARY KEY (id);


--
-- Name: ai_agents ai_agents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agents
    ADD CONSTRAINT ai_agents_pkey PRIMARY KEY (id);


--
-- Name: ai_analytics_runs ai_analytics_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_analytics_runs
    ADD CONSTRAINT ai_analytics_runs_pkey PRIMARY KEY (id);


--
-- Name: ai_analytics_usages ai_analytics_usages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_analytics_usages
    ADD CONSTRAINT ai_analytics_usages_pkey PRIMARY KEY (id);


--
-- Name: ai_stored_results ai_stored_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_stored_results
    ADD CONSTRAINT ai_stored_results_pkey PRIMARY KEY (id);


--
-- Name: ai_text_tools ai_text_tools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_text_tools
    ADD CONSTRAINT ai_text_tools_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: authorizations authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authorizations
    ADD CONSTRAINT authorizations_pkey PRIMARY KEY (id);


--
-- Name: avatars avatars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avatars
    ADD CONSTRAINT avatars_pkey PRIMARY KEY (id);


--
-- Name: calendars calendars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendars
    ADD CONSTRAINT calendars_pkey PRIMARY KEY (id);


--
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- Name: chat_agents chat_agents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_agents
    ADD CONSTRAINT chat_agents_pkey PRIMARY KEY (id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: chat_sessions chat_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT chat_sessions_pkey PRIMARY KEY (id);


--
-- Name: chats chats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_pkey PRIMARY KEY (id);


--
-- Name: checklist_items checklist_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_items
    ADD CONSTRAINT checklist_items_pkey PRIMARY KEY (id);


--
-- Name: checklist_template_items checklist_template_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_template_items
    ADD CONSTRAINT checklist_template_items_pkey PRIMARY KEY (id);


--
-- Name: checklist_templates checklist_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_pkey PRIMARY KEY (id);


--
-- Name: checklists checklists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklists
    ADD CONSTRAINT checklists_pkey PRIMARY KEY (id);


--
-- Name: core_workflows core_workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workflows
    ADD CONSTRAINT core_workflows_pkey PRIMARY KEY (id);


--
-- Name: cti_caller_ids cti_caller_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cti_caller_ids
    ADD CONSTRAINT cti_caller_ids_pkey PRIMARY KEY (id);


--
-- Name: cti_logs cti_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cti_logs
    ADD CONSTRAINT cti_logs_pkey PRIMARY KEY (id);


--
-- Name: data_privacy_tasks data_privacy_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_privacy_tasks
    ADD CONSTRAINT data_privacy_tasks_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: email_addresses email_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses
    ADD CONSTRAINT email_addresses_pkey PRIMARY KEY (id);


--
-- Name: external_credentials external_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_credentials
    ADD CONSTRAINT external_credentials_pkey PRIMARY KEY (id);


--
-- Name: external_syncs external_syncs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_syncs
    ADD CONSTRAINT external_syncs_pkey PRIMARY KEY (id);


--
-- Name: failed_emails failed_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_emails
    ADD CONSTRAINT failed_emails_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: histories histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.histories
    ADD CONSTRAINT histories_pkey PRIMARY KEY (id);


--
-- Name: history_attributes history_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history_attributes
    ADD CONSTRAINT history_attributes_pkey PRIMARY KEY (id);


--
-- Name: history_objects history_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history_objects
    ADD CONSTRAINT history_objects_pkey PRIMARY KEY (id);


--
-- Name: history_types history_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history_types
    ADD CONSTRAINT history_types_pkey PRIMARY KEY (id);


--
-- Name: http_logs http_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.http_logs
    ADD CONSTRAINT http_logs_pkey PRIMARY KEY (id);


--
-- Name: import_jobs import_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_jobs
    ADD CONSTRAINT import_jobs_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_answer_translation_contents knowledge_base_answer_translation_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answer_translation_contents
    ADD CONSTRAINT knowledge_base_answer_translation_contents_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_answer_translations knowledge_base_answer_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answer_translations
    ADD CONSTRAINT knowledge_base_answer_translations_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_answers knowledge_base_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answers
    ADD CONSTRAINT knowledge_base_answers_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_categories knowledge_base_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_categories
    ADD CONSTRAINT knowledge_base_categories_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_category_translations knowledge_base_category_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_category_translations
    ADD CONSTRAINT knowledge_base_category_translations_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_locales knowledge_base_locales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_locales
    ADD CONSTRAINT knowledge_base_locales_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_menu_items knowledge_base_menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_menu_items
    ADD CONSTRAINT knowledge_base_menu_items_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_permissions knowledge_base_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_permissions
    ADD CONSTRAINT knowledge_base_permissions_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_translations knowledge_base_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_translations
    ADD CONSTRAINT knowledge_base_translations_pkey PRIMARY KEY (id);


--
-- Name: knowledge_bases knowledge_bases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_bases
    ADD CONSTRAINT knowledge_bases_pkey PRIMARY KEY (id);


--
-- Name: ldap_sources ldap_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_sources
    ADD CONSTRAINT ldap_sources_pkey PRIMARY KEY (id);


--
-- Name: link_objects link_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_objects
    ADD CONSTRAINT link_objects_pkey PRIMARY KEY (id);


--
-- Name: link_types link_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_types
    ADD CONSTRAINT link_types_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: locales locales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locales
    ADD CONSTRAINT locales_pkey PRIMARY KEY (id);


--
-- Name: macros macros_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.macros
    ADD CONSTRAINT macros_pkey PRIMARY KEY (id);


--
-- Name: mentions mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: object_lookups object_lookups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_lookups
    ADD CONSTRAINT object_lookups_pkey PRIMARY KEY (id);


--
-- Name: object_manager_attributes object_manager_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_manager_attributes
    ADD CONSTRAINT object_manager_attributes_pkey PRIMARY KEY (id);


--
-- Name: online_notification_standalones online_notification_standalones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_notification_standalones
    ADD CONSTRAINT online_notification_standalones_pkey PRIMARY KEY (id);


--
-- Name: online_notifications online_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_notifications
    ADD CONSTRAINT online_notifications_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: overviews overviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overviews
    ADD CONSTRAINT overviews_pkey PRIMARY KEY (id);


--
-- Name: package_migrations package_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_migrations
    ADD CONSTRAINT package_migrations_pkey PRIMARY KEY (id);


--
-- Name: packages packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT packages_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: pgp_keys pgp_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgp_keys
    ADD CONSTRAINT pgp_keys_pkey PRIMARY KEY (id);


--
-- Name: postmaster_filters postmaster_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postmaster_filters
    ADD CONSTRAINT postmaster_filters_pkey PRIMARY KEY (id);


--
-- Name: public_links public_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_links
    ADD CONSTRAINT public_links_pkey PRIMARY KEY (id);


--
-- Name: recent_closes recent_closes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recent_closes
    ADD CONSTRAINT recent_closes_pkey PRIMARY KEY (id);


--
-- Name: recent_views recent_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recent_views
    ADD CONSTRAINT recent_views_pkey PRIMARY KEY (id);


--
-- Name: report_profiles report_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_profiles
    ADD CONSTRAINT report_profiles_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schedulers schedulers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedulers
    ADD CONSTRAINT schedulers_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: signatures signatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signatures
    ADD CONSTRAINT signatures_pkey PRIMARY KEY (id);


--
-- Name: slas slas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slas
    ADD CONSTRAINT slas_pkey PRIMARY KEY (id);


--
-- Name: smime_certificates smime_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.smime_certificates
    ADD CONSTRAINT smime_certificates_pkey PRIMARY KEY (id);


--
-- Name: ssl_certificates ssl_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ssl_certificates
    ADD CONSTRAINT ssl_certificates_pkey PRIMARY KEY (id);


--
-- Name: stats_stores stats_stores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stats_stores
    ADD CONSTRAINT stats_stores_pkey PRIMARY KEY (id);


--
-- Name: store_files store_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_files
    ADD CONSTRAINT store_files_pkey PRIMARY KEY (id);


--
-- Name: store_objects store_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_objects
    ADD CONSTRAINT store_objects_pkey PRIMARY KEY (id);


--
-- Name: store_provider_dbs store_provider_dbs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_provider_dbs
    ADD CONSTRAINT store_provider_dbs_pkey PRIMARY KEY (id);


--
-- Name: stores stores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- Name: system_reports system_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_reports
    ADD CONSTRAINT system_reports_pkey PRIMARY KEY (id);


--
-- Name: tag_items tag_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_items
    ADD CONSTRAINT tag_items_pkey PRIMARY KEY (id);


--
-- Name: tag_objects tag_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_objects
    ADD CONSTRAINT tag_objects_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: taskbars taskbars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taskbars
    ADD CONSTRAINT taskbars_pkey PRIMARY KEY (id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: text_modules text_modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_modules
    ADD CONSTRAINT text_modules_pkey PRIMARY KEY (id);


--
-- Name: ticket_article_flags ticket_article_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_flags
    ADD CONSTRAINT ticket_article_flags_pkey PRIMARY KEY (id);


--
-- Name: ticket_article_senders ticket_article_senders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_senders
    ADD CONSTRAINT ticket_article_senders_pkey PRIMARY KEY (id);


--
-- Name: ticket_article_types ticket_article_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_types
    ADD CONSTRAINT ticket_article_types_pkey PRIMARY KEY (id);


--
-- Name: ticket_articles ticket_articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_articles
    ADD CONSTRAINT ticket_articles_pkey PRIMARY KEY (id);


--
-- Name: ticket_counters ticket_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_counters
    ADD CONSTRAINT ticket_counters_pkey PRIMARY KEY (id);


--
-- Name: ticket_daily_event_locks ticket_daily_event_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_daily_event_locks
    ADD CONSTRAINT ticket_daily_event_locks_pkey PRIMARY KEY (id);


--
-- Name: ticket_priorities ticket_priorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_priorities
    ADD CONSTRAINT ticket_priorities_pkey PRIMARY KEY (id);


--
-- Name: ticket_shared_draft_starts ticket_shared_draft_starts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_shared_draft_starts
    ADD CONSTRAINT ticket_shared_draft_starts_pkey PRIMARY KEY (id);


--
-- Name: ticket_shared_draft_zooms ticket_shared_draft_zooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_shared_draft_zooms
    ADD CONSTRAINT ticket_shared_draft_zooms_pkey PRIMARY KEY (id);


--
-- Name: ticket_state_types ticket_state_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_state_types
    ADD CONSTRAINT ticket_state_types_pkey PRIMARY KEY (id);


--
-- Name: ticket_states ticket_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_states
    ADD CONSTRAINT ticket_states_pkey PRIMARY KEY (id);


--
-- Name: ticket_time_accounting_types ticket_time_accounting_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_time_accounting_types
    ADD CONSTRAINT ticket_time_accounting_types_pkey PRIMARY KEY (id);


--
-- Name: ticket_time_accountings ticket_time_accountings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_time_accountings
    ADD CONSTRAINT ticket_time_accountings_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: translations translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translations
    ADD CONSTRAINT translations_pkey PRIMARY KEY (id);


--
-- Name: triggers triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.triggers
    ADD CONSTRAINT triggers_pkey PRIMARY KEY (id);


--
-- Name: type_lookups type_lookups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.type_lookups
    ADD CONSTRAINT type_lookups_pkey PRIMARY KEY (id);


--
-- Name: user_devices user_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT user_devices_pkey PRIMARY KEY (id);


--
-- Name: user_overview_sortings user_overview_sortings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_overview_sortings
    ADD CONSTRAINT user_overview_sortings_pkey PRIMARY KEY (id);


--
-- Name: user_two_factor_preferences user_two_factor_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_two_factor_preferences
    ADD CONSTRAINT user_two_factor_preferences_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: index_active_job_locks_on_active_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_job_locks_on_active_job_id ON public.active_job_locks USING btree (active_job_id);


--
-- Name: index_active_job_locks_on_lock_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_job_locks_on_lock_key ON public.active_job_locks USING btree (lock_key);


--
-- Name: index_activity_streams_on_activity_stream_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_streams_on_activity_stream_object_id ON public.activity_streams USING btree (activity_stream_object_id);


--
-- Name: index_activity_streams_on_activity_stream_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_streams_on_activity_stream_type_id ON public.activity_streams USING btree (activity_stream_type_id);


--
-- Name: index_activity_streams_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_streams_on_created_at ON public.activity_streams USING btree (created_at);


--
-- Name: index_activity_streams_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_streams_on_created_by_id ON public.activity_streams USING btree (created_by_id);


--
-- Name: index_activity_streams_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_streams_on_group_id ON public.activity_streams USING btree (group_id);


--
-- Name: index_activity_streams_on_o_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_streams_on_o_id ON public.activity_streams USING btree (o_id);


--
-- Name: index_activity_streams_on_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_streams_on_permission_id ON public.activity_streams USING btree (permission_id);


--
-- Name: index_activity_streams_on_permission_id_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_streams_on_permission_id_and_group_id ON public.activity_streams USING btree (permission_id, group_id);


--
-- Name: index_activity_streams_on_permission_id_group_id_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_streams_on_permission_id_group_id_created_at ON public.activity_streams USING btree (permission_id, group_id, created_at);


--
-- Name: index_ai_agents_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ai_agents_on_active ON public.ai_agents USING btree (active);


--
-- Name: index_ai_agents_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ai_agents_on_name ON public.ai_agents USING btree (lower((name)::text));


--
-- Name: index_ai_analytics_runs_on_ai_service_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ai_analytics_runs_on_ai_service_name ON public.ai_analytics_runs USING btree (lower((ai_service_name)::text));


--
-- Name: index_ai_analytics_runs_on_triggered_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ai_analytics_runs_on_triggered_by ON public.ai_analytics_runs USING btree (triggered_by_type, triggered_by_id);


--
-- Name: index_ai_analytics_usages_on_ai_analytics_run_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ai_analytics_usages_on_ai_analytics_run_id_and_user_id ON public.ai_analytics_usages USING btree (ai_analytics_run_id, user_id);


--
-- Name: index_ai_analytics_usages_on_run_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ai_analytics_usages_on_run_id_and_created_at ON public.ai_analytics_usages USING btree (ai_analytics_run_id, created_at);


--
-- Name: index_ai_stored_results_on_identifier_and_other; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ai_stored_results_on_identifier_and_other ON public.ai_stored_results USING btree (identifier, locale_id, related_object_id, related_object_type);


--
-- Name: index_ai_stored_results_on_related_object; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ai_stored_results_on_related_object ON public.ai_stored_results USING btree (related_object_type, related_object_id);


--
-- Name: index_ai_text_tools_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ai_text_tools_groups_on_group_id ON public.ai_text_tools_groups USING btree (group_id);


--
-- Name: index_ai_text_tools_groups_on_text_tool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ai_text_tools_groups_on_text_tool_id ON public.ai_text_tools_groups USING btree (text_tool_id);


--
-- Name: index_ai_text_tools_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ai_text_tools_on_active ON public.ai_text_tools USING btree (active);


--
-- Name: index_ai_text_tools_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ai_text_tools_on_name ON public.ai_text_tools USING btree (lower((name)::text));


--
-- Name: index_authorizations_on_uid_and_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_authorizations_on_uid_and_provider ON public.authorizations USING btree (uid, provider);


--
-- Name: index_authorizations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorizations_on_user_id ON public.authorizations USING btree (user_id);


--
-- Name: index_authorizations_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorizations_on_username ON public.authorizations USING btree (lower((username)::text));


--
-- Name: index_avatars_on_default; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_avatars_on_default ON public.avatars USING btree ("default");


--
-- Name: index_avatars_on_o_id_and_object_lookup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_avatars_on_o_id_and_object_lookup_id ON public.avatars USING btree (o_id, object_lookup_id);


--
-- Name: index_avatars_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_avatars_on_source ON public.avatars USING btree (source);


--
-- Name: index_avatars_on_store_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_avatars_on_store_hash ON public.avatars USING btree (store_hash);


--
-- Name: index_calendars_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_calendars_on_name ON public.calendars USING btree (lower((name)::text));


--
-- Name: index_channels_on_area; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_channels_on_area ON public.channels USING btree (area);


--
-- Name: index_chat_agents_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chat_agents_on_active ON public.chat_agents USING btree (active);


--
-- Name: index_chat_agents_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_chat_agents_on_created_by_id ON public.chat_agents USING btree (created_by_id);


--
-- Name: index_chat_agents_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_chat_agents_on_updated_by_id ON public.chat_agents USING btree (updated_by_id);


--
-- Name: index_chat_messages_on_chat_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chat_messages_on_chat_session_id ON public.chat_messages USING btree (chat_session_id);


--
-- Name: index_chat_sessions_on_chat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chat_sessions_on_chat_id ON public.chat_sessions USING btree (chat_id);


--
-- Name: index_chat_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chat_sessions_on_session_id ON public.chat_sessions USING btree (session_id);


--
-- Name: index_chat_sessions_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chat_sessions_on_state ON public.chat_sessions USING btree (state);


--
-- Name: index_chat_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chat_sessions_on_user_id ON public.chat_sessions USING btree (user_id);


--
-- Name: index_chats_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_chats_on_name ON public.chats USING btree (lower((name)::text));


--
-- Name: index_checklist_items_on_checked; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_checklist_items_on_checked ON public.checklist_items USING btree (checked);


--
-- Name: index_checklist_templates_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_checklist_templates_on_active ON public.checklist_templates USING btree (active);


--
-- Name: index_core_workflows_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_core_workflows_on_name ON public.core_workflows USING btree (lower((name)::text));


--
-- Name: index_cti_caller_ids_on_caller_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cti_caller_ids_on_caller_id ON public.cti_caller_ids USING btree (caller_id);


--
-- Name: index_cti_caller_ids_on_caller_id_and_level; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cti_caller_ids_on_caller_id_and_level ON public.cti_caller_ids USING btree (caller_id, level);


--
-- Name: index_cti_caller_ids_on_caller_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cti_caller_ids_on_caller_id_and_user_id ON public.cti_caller_ids USING btree (caller_id, user_id);


--
-- Name: index_cti_caller_ids_on_object_and_o_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cti_caller_ids_on_object_and_o_id ON public.cti_caller_ids USING btree (object, o_id);


--
-- Name: index_cti_caller_ids_on_object_o_id_level_user_id_caller_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cti_caller_ids_on_object_o_id_level_user_id_caller_id ON public.cti_caller_ids USING btree (object, o_id, level, user_id, caller_id);


--
-- Name: index_cti_logs_on_call_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_cti_logs_on_call_id ON public.cti_logs USING btree (call_id);


--
-- Name: index_cti_logs_on_direction; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cti_logs_on_direction ON public.cti_logs USING btree (direction);


--
-- Name: index_cti_logs_on_from; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cti_logs_on_from ON public.cti_logs USING btree ("from");


--
-- Name: index_daily_event_locks_on_unique_fields; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_daily_event_locks_on_unique_fields ON public.ticket_daily_event_locks USING btree (date, lock_type, lock_activator, ticket_id, related_object_type, related_object_id);


--
-- Name: index_data_privacy_tasks_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_data_privacy_tasks_on_state ON public.data_privacy_tasks USING btree (state);


--
-- Name: index_delayed_jobs_on_active_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_active_job_id ON public.delayed_jobs USING btree (active_job_id);


--
-- Name: index_email_addresses_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_email_addresses_on_email ON public.email_addresses USING btree (email);


--
-- Name: index_external_syncs_on_object_and_o_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_syncs_on_object_and_o_id ON public.external_syncs USING btree (object, o_id);


--
-- Name: index_external_syncs_on_source_and_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_external_syncs_on_source_and_source_id ON public.external_syncs USING btree (source, source_id);


--
-- Name: index_external_syncs_on_source_and_source_id_and_object_o_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_syncs_on_source_and_source_id_and_object_o_id ON public.external_syncs USING btree (source, source_id, object, o_id);


--
-- Name: index_groups_macros_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_macros_on_group_id ON public.groups_macros USING btree (group_id);


--
-- Name: index_groups_macros_on_macro_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_macros_on_macro_id ON public.groups_macros USING btree (macro_id);


--
-- Name: index_groups_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_groups_on_name ON public.groups USING btree (lower((name)::text));


--
-- Name: index_groups_text_modules_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_text_modules_on_group_id ON public.groups_text_modules USING btree (group_id);


--
-- Name: index_groups_text_modules_on_text_module_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_text_modules_on_text_module_id ON public.groups_text_modules USING btree (text_module_id);


--
-- Name: index_groups_users_on_access; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_users_on_access ON public.groups_users USING btree (access);


--
-- Name: index_groups_users_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_users_on_group_id ON public.groups_users USING btree (group_id);


--
-- Name: index_groups_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_users_on_user_id ON public.groups_users USING btree (user_id);


--
-- Name: index_groups_users_on_user_id_and_group_id_and_access; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_users_on_user_id_and_group_id_and_access ON public.groups_users USING btree (user_id, group_id, access);


--
-- Name: index_histories_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_created_at ON public.histories USING btree (created_at);


--
-- Name: index_histories_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_created_by_id ON public.histories USING btree (created_by_id);


--
-- Name: index_histories_on_history_attribute_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_history_attribute_id ON public.histories USING btree (history_attribute_id);


--
-- Name: index_histories_on_history_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_history_object_id ON public.histories USING btree (history_object_id);


--
-- Name: index_histories_on_history_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_history_type_id ON public.histories USING btree (history_type_id);


--
-- Name: index_histories_on_id_from; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_id_from ON public.histories USING btree (id_from);


--
-- Name: index_histories_on_id_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_id_to ON public.histories USING btree (id_to);


--
-- Name: index_histories_on_o_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_o_id ON public.histories USING btree (o_id);


--
-- Name: index_histories_on_o_id_and_history_object_id_and_related_o_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_o_id_and_history_object_id_and_related_o_id ON public.histories USING btree (o_id, history_object_id, related_o_id);


--
-- Name: index_histories_on_related_history_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_related_history_object_id ON public.histories USING btree (related_history_object_id);


--
-- Name: index_histories_on_related_o_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_related_o_id ON public.histories USING btree (related_o_id);


--
-- Name: index_histories_on_value_from; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_value_from ON public.histories USING btree (value_from);


--
-- Name: index_histories_on_value_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_value_to ON public.histories USING btree (value_to);


--
-- Name: index_history_attributes_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_history_attributes_on_name ON public.history_attributes USING btree (lower((name)::text));


--
-- Name: index_history_objects_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_history_objects_on_name ON public.history_objects USING btree (lower((name)::text));


--
-- Name: index_history_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_history_types_on_name ON public.history_types USING btree (lower((name)::text));


--
-- Name: index_http_logs_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_http_logs_on_created_at ON public.http_logs USING btree (created_at);


--
-- Name: index_http_logs_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_http_logs_on_created_by_id ON public.http_logs USING btree (created_by_id);


--
-- Name: index_http_logs_on_facility; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_http_logs_on_facility ON public.http_logs USING btree (facility);


--
-- Name: index_jobs_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jobs_on_name ON public.jobs USING btree (lower((name)::text));


--
-- Name: index_kb_a_t_on_kb_locale_answer; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_kb_a_t_on_kb_locale_answer ON public.knowledge_base_answer_translations USING btree (kb_locale_id, answer_id);


--
-- Name: index_kb_answers_publishing_dates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kb_answers_publishing_dates ON public.knowledge_base_answers USING btree (published_at, archived_at, internal_at);


--
-- Name: index_kb_c_t_on_kb_locale_category; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_kb_c_t_on_kb_locale_category ON public.knowledge_base_category_translations USING btree (kb_locale_id, category_id);


--
-- Name: index_kb_locale_on_kb_system_locale_kb; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_kb_locale_on_kb_system_locale_kb ON public.knowledge_base_locales USING btree (system_locale_id, knowledge_base_id);


--
-- Name: index_kb_t_on_kb_locale_kb; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_kb_t_on_kb_locale_kb ON public.knowledge_base_translations USING btree (kb_locale_id, knowledge_base_id);


--
-- Name: index_knowledge_base_answer_translations_on_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_answer_translations_on_answer_id ON public.knowledge_base_answer_translations USING btree (answer_id);


--
-- Name: index_knowledge_base_answer_translations_on_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_answer_translations_on_content_id ON public.knowledge_base_answer_translations USING btree (content_id);


--
-- Name: index_knowledge_base_answer_translations_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_answer_translations_on_created_by_id ON public.knowledge_base_answer_translations USING btree (created_by_id);


--
-- Name: index_knowledge_base_answer_translations_on_kb_locale_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_answer_translations_on_kb_locale_id ON public.knowledge_base_answer_translations USING btree (kb_locale_id);


--
-- Name: index_knowledge_base_answer_translations_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_answer_translations_on_updated_by_id ON public.knowledge_base_answer_translations USING btree (updated_by_id);


--
-- Name: index_knowledge_base_answers_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_answers_on_archived_at ON public.knowledge_base_answers USING btree (archived_at);


--
-- Name: index_knowledge_base_answers_on_archived_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_answers_on_archived_by_id ON public.knowledge_base_answers USING btree (archived_by_id);


--
-- Name: index_knowledge_base_answers_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_answers_on_category_id ON public.knowledge_base_answers USING btree (category_id);


--
-- Name: index_knowledge_base_answers_on_internal_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_answers_on_internal_by_id ON public.knowledge_base_answers USING btree (internal_by_id);


--
-- Name: index_knowledge_base_answers_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_answers_on_position ON public.knowledge_base_answers USING btree ("position");


--
-- Name: index_knowledge_base_answers_on_published_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_answers_on_published_by_id ON public.knowledge_base_answers USING btree (published_by_id);


--
-- Name: index_knowledge_base_categories_on_knowledge_base_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_categories_on_knowledge_base_id ON public.knowledge_base_categories USING btree (knowledge_base_id);


--
-- Name: index_knowledge_base_categories_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_categories_on_parent_id ON public.knowledge_base_categories USING btree (parent_id);


--
-- Name: index_knowledge_base_categories_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_categories_on_position ON public.knowledge_base_categories USING btree ("position");


--
-- Name: index_knowledge_base_category_translations_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_category_translations_on_category_id ON public.knowledge_base_category_translations USING btree (category_id);


--
-- Name: index_knowledge_base_category_translations_on_kb_locale_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_category_translations_on_kb_locale_id ON public.knowledge_base_category_translations USING btree (kb_locale_id);


--
-- Name: index_knowledge_base_locales_on_knowledge_base_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_locales_on_knowledge_base_id ON public.knowledge_base_locales USING btree (knowledge_base_id);


--
-- Name: index_knowledge_base_locales_on_system_locale_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_locales_on_system_locale_id ON public.knowledge_base_locales USING btree (system_locale_id);


--
-- Name: index_knowledge_base_menu_items_on_kb_locale_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_menu_items_on_kb_locale_id ON public.knowledge_base_menu_items USING btree (kb_locale_id);


--
-- Name: index_knowledge_base_menu_items_on_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_menu_items_on_location ON public.knowledge_base_menu_items USING btree (location);


--
-- Name: index_knowledge_base_menu_items_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_menu_items_on_position ON public.knowledge_base_menu_items USING btree ("position");


--
-- Name: index_knowledge_base_permissions_on_access; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_permissions_on_access ON public.knowledge_base_permissions USING btree (access);


--
-- Name: index_knowledge_base_permissions_on_permissionable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_permissions_on_permissionable ON public.knowledge_base_permissions USING btree (permissionable_type, permissionable_id);


--
-- Name: index_knowledge_base_permissions_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_permissions_on_role_id ON public.knowledge_base_permissions USING btree (role_id);


--
-- Name: index_knowledge_base_translations_on_kb_locale_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_translations_on_kb_locale_id ON public.knowledge_base_translations USING btree (kb_locale_id);


--
-- Name: index_knowledge_base_translations_on_knowledge_base_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_base_translations_on_knowledge_base_id ON public.knowledge_base_translations USING btree (knowledge_base_id);


--
-- Name: index_ldap_sources_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ldap_sources_on_name ON public.ldap_sources USING btree (lower((name)::text));


--
-- Name: index_link_objects_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_link_objects_on_name ON public.link_objects USING btree (lower((name)::text));


--
-- Name: index_link_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_link_types_on_name ON public.link_types USING btree (lower((name)::text));


--
-- Name: index_locales_on_locale; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_locales_on_locale ON public.locales USING btree (lower((locale)::text));


--
-- Name: index_locales_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_locales_on_name ON public.locales USING btree (lower((name)::text));


--
-- Name: index_macros_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_macros_on_name ON public.macros USING btree (lower((name)::text));


--
-- Name: index_mentions_mentionable_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mentions_mentionable_user ON public.mentions USING btree (mentionable_id, mentionable_type, user_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_object_lookups_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_object_lookups_on_name ON public.object_lookups USING btree (lower((name)::text));


--
-- Name: index_object_manager_attributes_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_object_manager_attributes_on_active ON public.object_manager_attributes USING btree (active);


--
-- Name: index_object_manager_attributes_on_object_lookup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_object_manager_attributes_on_object_lookup_id ON public.object_manager_attributes USING btree (object_lookup_id);


--
-- Name: index_object_manager_attributes_on_object_lookup_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_object_manager_attributes_on_object_lookup_id_and_name ON public.object_manager_attributes USING btree (object_lookup_id, lower((name)::text));


--
-- Name: index_object_manager_attributes_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_object_manager_attributes_on_updated_at ON public.object_manager_attributes USING btree (updated_at);


--
-- Name: index_online_notifications_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_online_notifications_on_created_at ON public.online_notifications USING btree (created_at);


--
-- Name: index_online_notifications_on_seen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_online_notifications_on_seen ON public.online_notifications USING btree (seen);


--
-- Name: index_online_notifications_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_online_notifications_on_updated_at ON public.online_notifications USING btree (updated_at);


--
-- Name: index_online_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_online_notifications_on_user_id ON public.online_notifications USING btree (user_id);


--
-- Name: index_organizations_on_domain; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_domain ON public.organizations USING btree (domain);


--
-- Name: index_organizations_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_name ON public.organizations USING btree (lower((name)::text));


--
-- Name: index_organizations_users_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_users_on_organization_id ON public.organizations_users USING btree (organization_id);


--
-- Name: index_organizations_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_users_on_user_id ON public.organizations_users USING btree (user_id);


--
-- Name: index_out_of_office; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_out_of_office ON public.users USING btree (out_of_office, out_of_office_start_at, out_of_office_end_at);


--
-- Name: index_overviews_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_overviews_groups_on_group_id ON public.overviews_groups USING btree (group_id);


--
-- Name: index_overviews_groups_on_overview_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_overviews_groups_on_overview_id ON public.overviews_groups USING btree (overview_id);


--
-- Name: index_overviews_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_overviews_on_name ON public.overviews USING btree (lower((name)::text));


--
-- Name: index_overviews_roles_on_overview_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_overviews_roles_on_overview_id ON public.overviews_roles USING btree (overview_id);


--
-- Name: index_overviews_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_overviews_roles_on_role_id ON public.overviews_roles USING btree (role_id);


--
-- Name: index_overviews_users_on_overview_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_overviews_users_on_overview_id ON public.overviews_users USING btree (overview_id);


--
-- Name: index_overviews_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_overviews_users_on_user_id ON public.overviews_users USING btree (user_id);


--
-- Name: index_permissions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_name ON public.permissions USING btree (lower((name)::text));


--
-- Name: index_permissions_roles_on_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_roles_on_permission_id ON public.permissions_roles USING btree (permission_id);


--
-- Name: index_permissions_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_roles_on_role_id ON public.permissions_roles USING btree (role_id);


--
-- Name: index_pgp_keys_on_domain_alias; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pgp_keys_on_domain_alias ON public.pgp_keys USING btree (domain_alias);


--
-- Name: index_pgp_keys_on_fingerprint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pgp_keys_on_fingerprint ON public.pgp_keys USING btree (fingerprint);


--
-- Name: index_postmaster_filters_on_channel; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_postmaster_filters_on_channel ON public.postmaster_filters USING btree (channel);


--
-- Name: index_public_links_on_link; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_public_links_on_link ON public.public_links USING btree (link);


--
-- Name: index_recent_closed_user_object; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_recent_closed_user_object ON public.recent_closes USING btree (recently_closed_object_type, recently_closed_object_id, user_id);


--
-- Name: index_recent_closes_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recent_closes_on_updated_at ON public.recent_closes USING btree (updated_at DESC);


--
-- Name: index_recent_views_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recent_views_on_created_at ON public.recent_views USING btree (created_at);


--
-- Name: index_recent_views_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recent_views_on_created_by_id ON public.recent_views USING btree (created_by_id);


--
-- Name: index_recent_views_on_o_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recent_views_on_o_id ON public.recent_views USING btree (o_id);


--
-- Name: index_recent_views_on_recent_view_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recent_views_on_recent_view_object_id ON public.recent_views USING btree (recent_view_object_id);


--
-- Name: index_report_profiles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_report_profiles_on_name ON public.report_profiles USING btree (lower((name)::text));


--
-- Name: index_report_profiles_roles_on_profile_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_report_profiles_roles_on_profile_id ON public.report_profiles_roles USING btree (profile_id);


--
-- Name: index_report_profiles_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_report_profiles_roles_on_role_id ON public.report_profiles_roles USING btree (role_id);


--
-- Name: index_roles_groups_on_access; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_groups_on_access ON public.roles_groups USING btree (access);


--
-- Name: index_roles_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_groups_on_group_id ON public.roles_groups USING btree (group_id);


--
-- Name: index_roles_groups_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_groups_on_role_id ON public.roles_groups USING btree (role_id);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_name ON public.roles USING btree (lower((name)::text));


--
-- Name: index_roles_users_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_users_on_role_id ON public.roles_users USING btree (role_id);


--
-- Name: index_roles_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_users_on_user_id ON public.roles_users USING btree (user_id);


--
-- Name: index_schedulers_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schedulers_on_name ON public.schedulers USING btree (lower((name)::text));


--
-- Name: index_sessions_on_persistent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_persistent ON public.sessions USING btree (persistent);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_session_id ON public.sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON public.sessions USING btree (updated_at);


--
-- Name: index_settings_on_area; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_settings_on_area ON public.settings USING btree (area);


--
-- Name: index_settings_on_frontend; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_settings_on_frontend ON public.settings USING btree (frontend);


--
-- Name: index_settings_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_settings_on_name ON public.settings USING btree (lower((name)::text));


--
-- Name: index_signatures_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_signatures_on_name ON public.signatures USING btree (lower((name)::text));


--
-- Name: index_slas_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_slas_on_name ON public.slas USING btree (lower((name)::text));


--
-- Name: index_smime_certificates_on_fingerprint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_smime_certificates_on_fingerprint ON public.smime_certificates USING btree (fingerprint);


--
-- Name: index_smime_certificates_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_smime_certificates_on_uid ON public.smime_certificates USING btree (uid);


--
-- Name: index_stats_stores_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stats_stores_on_created_at ON public.stats_stores USING btree (created_at);


--
-- Name: index_stats_stores_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stats_stores_on_created_by_id ON public.stats_stores USING btree (created_by_id);


--
-- Name: index_stats_stores_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stats_stores_on_key ON public.stats_stores USING btree (key);


--
-- Name: index_stats_stores_on_stats_storable_type_and_stats_storable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stats_stores_on_stats_storable_type_and_stats_storable_id ON public.stats_stores USING btree (stats_storable_type, stats_storable_id);


--
-- Name: index_store_files_on_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_store_files_on_provider ON public.store_files USING btree (provider);


--
-- Name: index_store_files_on_sha; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_store_files_on_sha ON public.store_files USING btree (sha);


--
-- Name: index_store_objects_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_store_objects_on_name ON public.store_objects USING btree (lower((name)::text));


--
-- Name: index_store_provider_dbs_on_sha; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_store_provider_dbs_on_sha ON public.store_provider_dbs USING btree (sha);


--
-- Name: index_stores_on_store_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stores_on_store_file_id ON public.stores USING btree (store_file_id);


--
-- Name: index_stores_on_store_object_id_and_o_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stores_on_store_object_id_and_o_id ON public.stores USING btree (store_object_id, o_id);


--
-- Name: index_system_reports_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_system_reports_on_uuid ON public.system_reports USING btree (uuid);


--
-- Name: index_tag_items_on_name_downcase; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_items_on_name_downcase ON public.tag_items USING btree (name_downcase);


--
-- Name: index_tag_objects_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tag_objects_on_name ON public.tag_objects USING btree (lower((name)::text));


--
-- Name: index_tags_on_o_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_o_id ON public.tags USING btree (o_id);


--
-- Name: index_tags_on_tag_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_tag_object_id ON public.tags USING btree (tag_object_id);


--
-- Name: index_taskbars_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taskbars_on_key ON public.taskbars USING btree (key);


--
-- Name: index_taskbars_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taskbars_on_user_id ON public.taskbars USING btree (user_id);


--
-- Name: index_taskbars_on_user_id_and_key_and_app; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_taskbars_on_user_id_and_key_and_app ON public.taskbars USING btree (user_id, key, app);


--
-- Name: index_templates_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_on_name ON public.templates USING btree (lower((name)::text));


--
-- Name: index_text_modules_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_text_modules_on_name ON public.text_modules USING btree (lower((name)::text));


--
-- Name: index_ticket_article_flags_on_articles_id_and_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_article_flags_on_articles_id_and_created_by_id ON public.ticket_article_flags USING btree (ticket_article_id, created_by_id);


--
-- Name: index_ticket_article_flags_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_article_flags_on_created_by_id ON public.ticket_article_flags USING btree (created_by_id);


--
-- Name: index_ticket_article_flags_on_ticket_article_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_article_flags_on_ticket_article_id ON public.ticket_article_flags USING btree (ticket_article_id);


--
-- Name: index_ticket_article_flags_on_ticket_article_id_and_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_article_flags_on_ticket_article_id_and_key ON public.ticket_article_flags USING btree (ticket_article_id, key);


--
-- Name: index_ticket_article_senders_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticket_article_senders_on_name ON public.ticket_article_senders USING btree (lower((name)::text));


--
-- Name: index_ticket_article_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticket_article_types_on_name ON public.ticket_article_types USING btree (lower((name)::text));


--
-- Name: index_ticket_articles_message_id_md5_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_articles_message_id_md5_type_id ON public.ticket_articles USING btree (message_id_md5, type_id);


--
-- Name: index_ticket_articles_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_articles_on_created_at ON public.ticket_articles USING btree (created_at);


--
-- Name: index_ticket_articles_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_articles_on_created_by_id ON public.ticket_articles USING btree (created_by_id);


--
-- Name: index_ticket_articles_on_internal; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_articles_on_internal ON public.ticket_articles USING btree (internal);


--
-- Name: index_ticket_articles_on_message_id_md5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_articles_on_message_id_md5 ON public.ticket_articles USING btree (message_id_md5);


--
-- Name: index_ticket_articles_on_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_articles_on_sender_id ON public.ticket_articles USING btree (sender_id);


--
-- Name: index_ticket_articles_on_ticket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_articles_on_ticket_id ON public.ticket_articles USING btree (ticket_id);


--
-- Name: index_ticket_articles_on_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_articles_on_type_id ON public.ticket_articles USING btree (type_id);


--
-- Name: index_ticket_counters_on_generator; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticket_counters_on_generator ON public.ticket_counters USING btree (generator);


--
-- Name: index_ticket_priorities_on_default_create; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_priorities_on_default_create ON public.ticket_priorities USING btree (default_create);


--
-- Name: index_ticket_priorities_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticket_priorities_on_name ON public.ticket_priorities USING btree (lower((name)::text));


--
-- Name: index_ticket_state_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticket_state_types_on_name ON public.ticket_state_types USING btree (lower((name)::text));


--
-- Name: index_ticket_states_on_default_close; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_states_on_default_close ON public.ticket_states USING btree (default_close);


--
-- Name: index_ticket_states_on_default_create; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_states_on_default_create ON public.ticket_states USING btree (default_create);


--
-- Name: index_ticket_states_on_default_follow_up; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_states_on_default_follow_up ON public.ticket_states USING btree (default_follow_up);


--
-- Name: index_ticket_states_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticket_states_on_name ON public.ticket_states USING btree (lower((name)::text));


--
-- Name: index_ticket_time_accounting_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticket_time_accounting_types_on_name ON public.ticket_time_accounting_types USING btree (lower((name)::text));


--
-- Name: index_ticket_time_accountings_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_time_accountings_on_created_by_id ON public.ticket_time_accountings USING btree (created_by_id);


--
-- Name: index_ticket_time_accountings_on_ticket_article_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_time_accountings_on_ticket_article_id ON public.ticket_time_accountings USING btree (ticket_article_id);


--
-- Name: index_ticket_time_accountings_on_ticket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_time_accountings_on_ticket_id ON public.ticket_time_accountings USING btree (ticket_id);


--
-- Name: index_ticket_time_accountings_on_time_unit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_time_accountings_on_time_unit ON public.ticket_time_accountings USING btree (time_unit);


--
-- Name: index_tickets_on_ai_agent_running; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_ai_agent_running ON public.tickets USING btree (ai_agent_running);


--
-- Name: index_tickets_on_checklist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tickets_on_checklist_id ON public.tickets USING btree (checklist_id);


--
-- Name: index_tickets_on_close_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_close_at ON public.tickets USING btree (close_at);


--
-- Name: index_tickets_on_close_diff_in_min; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_close_diff_in_min ON public.tickets USING btree (close_diff_in_min);


--
-- Name: index_tickets_on_close_escalation_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_close_escalation_at ON public.tickets USING btree (close_escalation_at);


--
-- Name: index_tickets_on_close_in_min; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_close_in_min ON public.tickets USING btree (close_in_min);


--
-- Name: index_tickets_on_create_article_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_create_article_sender_id ON public.tickets USING btree (create_article_sender_id);


--
-- Name: index_tickets_on_create_article_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_create_article_type_id ON public.tickets USING btree (create_article_type_id);


--
-- Name: index_tickets_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_created_at ON public.tickets USING btree (created_at);


--
-- Name: index_tickets_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_created_by_id ON public.tickets USING btree (created_by_id);


--
-- Name: index_tickets_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_customer_id ON public.tickets USING btree (customer_id);


--
-- Name: index_tickets_on_customer_id_and_state_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_customer_id_and_state_id_and_created_at ON public.tickets USING btree (customer_id, state_id, created_at);


--
-- Name: index_tickets_on_escalation_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_escalation_at ON public.tickets USING btree (escalation_at);


--
-- Name: index_tickets_on_first_response_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_first_response_at ON public.tickets USING btree (first_response_at);


--
-- Name: index_tickets_on_first_response_diff_in_min; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_first_response_diff_in_min ON public.tickets USING btree (first_response_diff_in_min);


--
-- Name: index_tickets_on_first_response_escalation_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_first_response_escalation_at ON public.tickets USING btree (first_response_escalation_at);


--
-- Name: index_tickets_on_first_response_in_min; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_first_response_in_min ON public.tickets USING btree (first_response_in_min);


--
-- Name: index_tickets_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_group_id ON public.tickets USING btree (group_id);


--
-- Name: index_tickets_on_group_id_and_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_group_id_and_state_id ON public.tickets USING btree (group_id, state_id);


--
-- Name: index_tickets_on_group_id_and_state_id_and_close_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_group_id_and_state_id_and_close_at ON public.tickets USING btree (group_id, state_id, close_at);


--
-- Name: index_tickets_on_group_id_and_state_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_group_id_and_state_id_and_created_at ON public.tickets USING btree (group_id, state_id, created_at);


--
-- Name: index_tickets_on_group_id_and_state_id_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_group_id_and_state_id_and_owner_id ON public.tickets USING btree (group_id, state_id, owner_id);


--
-- Name: index_tickets_on_group_id_and_state_id_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_group_id_and_state_id_and_updated_at ON public.tickets USING btree (group_id, state_id, updated_at);


--
-- Name: index_tickets_on_group_id_state_id_owner_id_close_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_group_id_state_id_owner_id_close_at ON public.tickets USING btree (group_id, state_id, owner_id, close_at);


--
-- Name: index_tickets_on_group_id_state_id_owner_id_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_group_id_state_id_owner_id_created_at ON public.tickets USING btree (group_id, state_id, owner_id, created_at);


--
-- Name: index_tickets_on_group_id_state_id_owner_id_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_group_id_state_id_owner_id_updated_at ON public.tickets USING btree (group_id, state_id, owner_id, updated_at);


--
-- Name: index_tickets_on_last_contact_agent_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_last_contact_agent_at ON public.tickets USING btree (last_contact_agent_at);


--
-- Name: index_tickets_on_last_contact_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_last_contact_at ON public.tickets USING btree (last_contact_at);


--
-- Name: index_tickets_on_last_contact_customer_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_last_contact_customer_at ON public.tickets USING btree (last_contact_customer_at);


--
-- Name: index_tickets_on_last_owner_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_last_owner_update_at ON public.tickets USING btree (last_owner_update_at);


--
-- Name: index_tickets_on_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tickets_on_number ON public.tickets USING btree (number);


--
-- Name: index_tickets_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_owner_id ON public.tickets USING btree (owner_id);


--
-- Name: index_tickets_on_pending_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_pending_time ON public.tickets USING btree (pending_time);


--
-- Name: index_tickets_on_priority_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_priority_id ON public.tickets USING btree (priority_id);


--
-- Name: index_tickets_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_state_id ON public.tickets USING btree (state_id);


--
-- Name: index_tickets_on_time_unit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_time_unit ON public.tickets USING btree (time_unit);


--
-- Name: index_tickets_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_title ON public.tickets USING btree (title);


--
-- Name: index_tickets_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_type ON public.tickets USING btree (type);


--
-- Name: index_tickets_on_update_diff_in_min; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_update_diff_in_min ON public.tickets USING btree (update_diff_in_min);


--
-- Name: index_tickets_on_update_in_min; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_update_in_min ON public.tickets USING btree (update_in_min);


--
-- Name: index_tickets_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tickets_on_updated_at ON public.tickets USING btree (updated_at);


--
-- Name: index_tokens_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tokens_on_created_at ON public.tokens USING btree (created_at);


--
-- Name: index_tokens_on_persistent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tokens_on_persistent ON public.tokens USING btree (persistent);


--
-- Name: index_tokens_on_token_and_action; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tokens_on_token_and_action ON public.tokens USING btree (token, action);


--
-- Name: index_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tokens_on_user_id ON public.tokens USING btree (user_id);


--
-- Name: index_translations_on_locale; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_translations_on_locale ON public.translations USING btree (lower((locale)::text));


--
-- Name: index_translations_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_translations_on_source ON public.translations USING btree (source);


--
-- Name: index_triggers_on_active_and_activator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_triggers_on_active_and_activator ON public.triggers USING btree (active, activator);


--
-- Name: index_triggers_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_triggers_on_name ON public.triggers USING btree (lower((name)::text));


--
-- Name: index_type_lookups_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_type_lookups_on_name ON public.type_lookups USING btree (lower((name)::text));


--
-- Name: index_user_devices_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_devices_on_created_at ON public.user_devices USING btree (created_at);


--
-- Name: index_user_devices_on_fingerprint; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_devices_on_fingerprint ON public.user_devices USING btree (fingerprint);


--
-- Name: index_user_devices_on_os_and_browser_and_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_devices_on_os_and_browser_and_location ON public.user_devices USING btree (os, browser, location);


--
-- Name: index_user_devices_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_devices_on_updated_at ON public.user_devices USING btree (updated_at);


--
-- Name: index_user_devices_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_devices_on_user_id ON public.user_devices USING btree (user_id);


--
-- Name: index_user_overview_sortings_on_overview_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_overview_sortings_on_overview_id ON public.user_overview_sortings USING btree (overview_id);


--
-- Name: index_user_overview_sortings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_overview_sortings_on_user_id ON public.user_overview_sortings USING btree (user_id);


--
-- Name: index_user_two_factor_preferences_on_method_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_two_factor_preferences_on_method_and_user_id ON public.user_two_factor_preferences USING btree (method, user_id);


--
-- Name: index_users_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_created_by_id ON public.users USING btree (created_by_id);


--
-- Name: index_users_on_department; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_department ON public.users USING btree (department);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_fax; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_fax ON public.users USING btree (fax);


--
-- Name: index_users_on_image; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_image ON public.users USING btree (image);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_login ON public.users USING btree (lower((login)::text));


--
-- Name: index_users_on_mobile; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_mobile ON public.users USING btree (mobile);


--
-- Name: index_users_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_organization_id ON public.users USING btree (organization_id);


--
-- Name: index_users_on_out_of_office_replacement_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_out_of_office_replacement_id ON public.users USING btree (out_of_office_replacement_id);


--
-- Name: index_users_on_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_phone ON public.users USING btree (phone);


--
-- Name: index_users_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_source ON public.users USING btree (source);


--
-- Name: knowledge_base_permissions_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX knowledge_base_permissions_uniqueness ON public.knowledge_base_permissions USING btree (role_id, permissionable_id, permissionable_type);


--
-- Name: links_uniq_total; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX links_uniq_total ON public.links USING btree (link_object_source_id, link_object_source_value, link_object_target_id, link_object_target_value, link_type_id);


--
-- Name: ticket_article_types fk_rails_01020bb700; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_types
    ADD CONSTRAINT fk_rails_01020bb700 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: ai_text_tools_groups fk_rails_071f444908; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_text_tools_groups
    ADD CONSTRAINT fk_rails_071f444908 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: user_overview_sortings fk_rails_07211fbc85; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_overview_sortings
    ADD CONSTRAINT fk_rails_07211fbc85 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ticket_states fk_rails_0853e2d094; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_states
    ADD CONSTRAINT fk_rails_0853e2d094 FOREIGN KEY (state_type_id) REFERENCES public.ticket_state_types(id);


--
-- Name: user_two_factor_preferences fk_rails_088df61a33; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_two_factor_preferences
    ADD CONSTRAINT fk_rails_088df61a33 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: schedulers fk_rails_08966259e8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedulers
    ADD CONSTRAINT fk_rails_08966259e8 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: http_logs fk_rails_0a97b58d1a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.http_logs
    ADD CONSTRAINT fk_rails_0a97b58d1a FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: ticket_state_types fk_rails_0b22ef689c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_state_types
    ADD CONSTRAINT fk_rails_0b22ef689c FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: online_notifications fk_rails_0c0055c5df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_notifications
    ADD CONSTRAINT fk_rails_0c0055c5df FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: ticket_article_senders fk_rails_0d21d01513; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_senders
    ADD CONSTRAINT fk_rails_0d21d01513 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: histories fk_rails_0e64d284d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.histories
    ADD CONSTRAINT fk_rails_0e64d284d8 FOREIGN KEY (history_object_id) REFERENCES public.history_objects(id);


--
-- Name: overviews fk_rails_13fe2fde45; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overviews
    ADD CONSTRAINT fk_rails_13fe2fde45 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: slas fk_rails_15319a5af4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slas
    ADD CONSTRAINT fk_rails_15319a5af4 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: activity_streams fk_rails_15ed0d0859; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_streams
    ADD CONSTRAINT fk_rails_15ed0d0859 FOREIGN KEY (activity_stream_type_id) REFERENCES public.type_lookups(id);


--
-- Name: user_overview_sortings fk_rails_16d8008529; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_overview_sortings
    ADD CONSTRAINT fk_rails_16d8008529 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: stores fk_rails_17354e2aa6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT fk_rails_17354e2aa6 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: macros fk_rails_18961fdc52; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.macros
    ADD CONSTRAINT fk_rails_18961fdc52 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: calendars fk_rails_1923375e08; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendars
    ADD CONSTRAINT fk_rails_1923375e08 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_locales fk_rails_196860d080; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_locales
    ADD CONSTRAINT fk_rails_196860d080 FOREIGN KEY (system_locale_id) REFERENCES public.locales(id);


--
-- Name: organizations_users fk_rails_1a7373774d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_users
    ADD CONSTRAINT fk_rails_1a7373774d FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: mentions fk_rails_1b711e94aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT fk_rails_1b711e94aa FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ticket_time_accounting_types fk_rails_1e8c31a747; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_time_accounting_types
    ADD CONSTRAINT fk_rails_1e8c31a747 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_answer_translations fk_rails_20d30feefb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answer_translations
    ADD CONSTRAINT fk_rails_20d30feefb FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: ldap_sources fk_rails_2120d99ef7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_sources
    ADD CONSTRAINT fk_rails_2120d99ef7 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: report_profiles fk_rails_214a4c247b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_profiles
    ADD CONSTRAINT fk_rails_214a4c247b FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: checklist_template_items fk_rails_2204ad0348; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_template_items
    ADD CONSTRAINT fk_rails_2204ad0348 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_permissions fk_rails_258456d7fe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_permissions
    ADD CONSTRAINT fk_rails_258456d7fe FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: ticket_shared_draft_zooms fk_rails_260153f4d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_shared_draft_zooms
    ADD CONSTRAINT fk_rails_260153f4d6 FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: roles_groups fk_rails_27be08e3f9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles_groups
    ADD CONSTRAINT fk_rails_27be08e3f9 FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: chat_sessions fk_rails_288ade3093; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT fk_rails_288ade3093 FOREIGN KEY (chat_id) REFERENCES public.chats(id);


--
-- Name: ticket_states fk_rails_2927b269ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_states
    ADD CONSTRAINT fk_rails_2927b269ed FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: ticket_shared_draft_starts fk_rails_29c078cd4e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_shared_draft_starts
    ADD CONSTRAINT fk_rails_29c078cd4e FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: knowledge_base_answer_translations fk_rails_2a0bd8e79b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answer_translations
    ADD CONSTRAINT fk_rails_2a0bd8e79b FOREIGN KEY (content_id) REFERENCES public.knowledge_base_answer_translation_contents(id);


--
-- Name: calendars fk_rails_2a2c81de1a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendars
    ADD CONSTRAINT fk_rails_2a2c81de1a FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: activity_streams fk_rails_2abed7f6ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_streams
    ADD CONSTRAINT fk_rails_2abed7f6ca FOREIGN KEY (permission_id) REFERENCES public.permissions(id);


--
-- Name: groups_macros fk_rails_2c7812f9b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_macros
    ADD CONSTRAINT fk_rails_2c7812f9b9 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: user_overview_sortings fk_rails_2eaee08c60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_overview_sortings
    ADD CONSTRAINT fk_rails_2eaee08c60 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_translations fk_rails_2f493e70d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_translations
    ADD CONSTRAINT fk_rails_2f493e70d8 FOREIGN KEY (kb_locale_id) REFERENCES public.knowledge_base_locales(id);


--
-- Name: public_links fk_rails_3033635a3a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_links
    ADD CONSTRAINT fk_rails_3033635a3a FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: histories fk_rails_317bea7955; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.histories
    ADD CONSTRAINT fk_rails_317bea7955 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: channels fk_rails_32268ed43d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT fk_rails_32268ed43d FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: user_two_factor_preferences fk_rails_331b8c0f48; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_two_factor_preferences
    ADD CONSTRAINT fk_rails_331b8c0f48 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: overviews_groups fk_rails_340cd150dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overviews_groups
    ADD CONSTRAINT fk_rails_340cd150dd FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: text_modules fk_rails_343b2c0fce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_modules
    ADD CONSTRAINT fk_rails_343b2c0fce FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: public_links fk_rails_350fadd8cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_links
    ADD CONSTRAINT fk_rails_350fadd8cc FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_355a7ffe95; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_355a7ffe95 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: triggers fk_rails_35c0846653; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.triggers
    ADD CONSTRAINT fk_rails_35c0846653 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: checklist_items fk_rails_3605ca8e4d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_items
    ADD CONSTRAINT fk_rails_3605ca8e4d FOREIGN KEY (checklist_id) REFERENCES public.checklists(id);


--
-- Name: avatars fk_rails_36592d9368; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avatars
    ADD CONSTRAINT fk_rails_36592d9368 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: ticket_articles fk_rails_38b783461b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_articles
    ADD CONSTRAINT fk_rails_38b783461b FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: ai_analytics_usages fk_rails_393e6ed17d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_analytics_usages
    ADD CONSTRAINT fk_rails_393e6ed17d FOREIGN KEY (ai_analytics_run_id) REFERENCES public.ai_analytics_runs(id);


--
-- Name: groups_text_modules fk_rails_39e2ed28bf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_text_modules
    ADD CONSTRAINT fk_rails_39e2ed28bf FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: ticket_article_flags fk_rails_3bc4ee2488; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_flags
    ADD CONSTRAINT fk_rails_3bc4ee2488 FOREIGN KEY (ticket_article_id) REFERENCES public.ticket_articles(id);


--
-- Name: ticket_articles fk_rails_3cb6a3675a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_articles
    ADD CONSTRAINT fk_rails_3cb6a3675a FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: jobs fk_rails_3e355905b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT fk_rails_3e355905b6 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: ai_text_tools_groups fk_rails_42340bd381; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_text_tools_groups
    ADD CONSTRAINT fk_rails_42340bd381 FOREIGN KEY (text_tool_id) REFERENCES public.ai_text_tools(id);


--
-- Name: packages fk_rails_438d68f470; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT fk_rails_438d68f470 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_45307c95a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_45307c95a3 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: templates fk_rails_4688f6dd32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT fk_rails_4688f6dd32 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: user_two_factor_preferences fk_rails_486740ea12; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_two_factor_preferences
    ADD CONSTRAINT fk_rails_486740ea12 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: ticket_states fk_rails_4a7d116edc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_states
    ADD CONSTRAINT fk_rails_4a7d116edc FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: chat_messages fk_rails_4ad9cc70bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT fk_rails_4ad9cc70bd FOREIGN KEY (chat_session_id) REFERENCES public.chat_sessions(id);


--
-- Name: postmaster_filters fk_rails_4b17873e0f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postmaster_filters
    ADD CONSTRAINT fk_rails_4b17873e0f FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: ticket_time_accountings fk_rails_4d0cbf7278; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_time_accountings
    ADD CONSTRAINT fk_rails_4d0cbf7278 FOREIGN KEY (ticket_article_id) REFERENCES public.ticket_articles(id);


--
-- Name: groups_users fk_rails_4e63edbd27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_users
    ADD CONSTRAINT fk_rails_4e63edbd27 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: authorizations fk_rails_4ecef5b8c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authorizations
    ADD CONSTRAINT fk_rails_4ecef5b8c5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: email_addresses fk_rails_4f204b5369; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses
    ADD CONSTRAINT fk_rails_4f204b5369 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: core_workflows fk_rails_50bf89399d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workflows
    ADD CONSTRAINT fk_rails_50bf89399d FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_locales fk_rails_50dd37ac55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_locales
    ADD CONSTRAINT fk_rails_50dd37ac55 FOREIGN KEY (knowledge_base_id) REFERENCES public.knowledge_bases(id);


--
-- Name: ai_analytics_runs fk_rails_518043b1cf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_analytics_runs
    ADD CONSTRAINT fk_rails_518043b1cf FOREIGN KEY (regeneration_of_id) REFERENCES public.ai_analytics_runs(id);


--
-- Name: ticket_article_types fk_rails_521ad892f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_types
    ADD CONSTRAINT fk_rails_521ad892f1 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: ticket_articles fk_rails_537ac1f42c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_articles
    ADD CONSTRAINT fk_rails_537ac1f42c FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: checklist_items fk_rails_543bc89e25; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_items
    ADD CONSTRAINT fk_rails_543bc89e25 FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: groups fk_rails_5538295cdc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_rails_5538295cdc FOREIGN KEY (signature_id) REFERENCES public.signatures(id);


--
-- Name: groups fk_rails_55ff2495b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_rails_55ff2495b5 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_answers fk_rails_564f85e760; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answers
    ADD CONSTRAINT fk_rails_564f85e760 FOREIGN KEY (published_by_id) REFERENCES public.users(id);


--
-- Name: tickets fk_rails_5685ed71b0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_5685ed71b0 FOREIGN KEY (customer_id) REFERENCES public.users(id);


--
-- Name: slas fk_rails_5a768af5b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slas
    ADD CONSTRAINT fk_rails_5a768af5b2 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: report_profiles_roles fk_rails_5c5fd57be9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_profiles_roles
    ADD CONSTRAINT fk_rails_5c5fd57be9 FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: knowledge_base_translations fk_rails_5c7ec5a7e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_translations
    ADD CONSTRAINT fk_rails_5c7ec5a7e3 FOREIGN KEY (knowledge_base_id) REFERENCES public.knowledge_bases(id) ON DELETE CASCADE;


--
-- Name: activity_streams fk_rails_5e0981116b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_streams
    ADD CONSTRAINT fk_rails_5e0981116b FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: core_workflows fk_rails_5e7c1bf746; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_workflows
    ADD CONSTRAINT fk_rails_5e7c1bf746 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: ai_stored_results fk_rails_5eb008681a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_stored_results
    ADD CONSTRAINT fk_rails_5eb008681a FOREIGN KEY (locale_id) REFERENCES public.locales(id);


--
-- Name: tags fk_rails_5f245fd6a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT fk_rails_5f245fd6a7 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: stores fk_rails_60bb0cecf9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT fk_rails_60bb0cecf9 FOREIGN KEY (store_file_id) REFERENCES public.store_files(id);


--
-- Name: checklist_templates fk_rails_63db34ce4d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT fk_rails_63db34ce4d FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_answer_translations fk_rails_65491af4b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answer_translations
    ADD CONSTRAINT fk_rails_65491af4b7 FOREIGN KEY (kb_locale_id) REFERENCES public.knowledge_base_locales(id);


--
-- Name: histories fk_rails_654f358220; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.histories
    ADD CONSTRAINT fk_rails_654f358220 FOREIGN KEY (history_type_id) REFERENCES public.history_types(id);


--
-- Name: ticket_article_flags fk_rails_6805881e8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_flags
    ADD CONSTRAINT fk_rails_6805881e8b FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: ai_agents fk_rails_6b0d0e5a98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agents
    ADD CONSTRAINT fk_rails_6b0d0e5a98 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: organizations fk_rails_6b945c40b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT fk_rails_6b945c40b8 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: chat_sessions fk_rails_6d2ee2e9b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT fk_rails_6d2ee2e9b7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ticket_state_types fk_rails_70faf2d7df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_state_types
    ADD CONSTRAINT fk_rails_70faf2d7df FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_categories fk_rails_71bea21159; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_categories
    ADD CONSTRAINT fk_rails_71bea21159 FOREIGN KEY (parent_id) REFERENCES public.knowledge_base_categories(id);


--
-- Name: oauth_access_tokens fk_rails_732cb83ab7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_732cb83ab7 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: knowledge_base_categories fk_rails_740cae2028; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_categories
    ADD CONSTRAINT fk_rails_740cae2028 FOREIGN KEY (knowledge_base_id) REFERENCES public.knowledge_bases(id);


--
-- Name: tickets fk_rails_75fe9c4648; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_75fe9c4648 FOREIGN KEY (priority_id) REFERENCES public.ticket_priorities(id);


--
-- Name: ticket_time_accounting_types fk_rails_7a0ce85612; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_time_accounting_types
    ADD CONSTRAINT fk_rails_7a0ce85612 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: ai_agents fk_rails_7a7e430c56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agents
    ADD CONSTRAINT fk_rails_7a7e430c56 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: checklist_items fk_rails_7b68a8f1d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_items
    ADD CONSTRAINT fk_rails_7b68a8f1d8 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: ticket_priorities fk_rails_7ba453ab6d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_priorities
    ADD CONSTRAINT fk_rails_7ba453ab6d FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: groups fk_rails_7bec5aff4f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_rails_7bec5aff4f FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: avatars fk_rails_7f23a117cf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avatars
    ADD CONSTRAINT fk_rails_7f23a117cf FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: triggers fk_rails_7f3d25350f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.triggers
    ADD CONSTRAINT fk_rails_7f3d25350f FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: groups_text_modules fk_rails_7f5cac0637; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_text_modules
    ADD CONSTRAINT fk_rails_7f5cac0637 FOREIGN KEY (text_module_id) REFERENCES public.text_modules(id);


--
-- Name: channels fk_rails_8011c05949; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT fk_rails_8011c05949 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: ldap_sources fk_rails_8285560e76; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_sources
    ADD CONSTRAINT fk_rails_8285560e76 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: signatures fk_rails_82877eeea3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signatures
    ADD CONSTRAINT fk_rails_82877eeea3 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: text_modules fk_rails_84148bfddb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.text_modules
    ADD CONSTRAINT fk_rails_84148bfddb FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: macros fk_rails_84f97aa218; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.macros
    ADD CONSTRAINT fk_rails_84f97aa218 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: groups_users fk_rails_8546c71994; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_users
    ADD CONSTRAINT fk_rails_8546c71994 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ticket_articles fk_rails_859725266a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_articles
    ADD CONSTRAINT fk_rails_859725266a FOREIGN KEY (sender_id) REFERENCES public.ticket_article_senders(id);


--
-- Name: packages fk_rails_86b7b71dbf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT fk_rails_86b7b71dbf FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_answers fk_rails_890b51fb27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answers
    ADD CONSTRAINT fk_rails_890b51fb27 FOREIGN KEY (internal_by_id) REFERENCES public.users(id);


--
-- Name: stats_stores fk_rails_8b167ccaf8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stats_stores
    ADD CONSTRAINT fk_rails_8b167ccaf8 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: translations fk_rails_8cb1380a17; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translations
    ADD CONSTRAINT fk_rails_8cb1380a17 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: activity_streams fk_rails_9006c69204; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_streams
    ADD CONSTRAINT fk_rails_9006c69204 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: chats fk_rails_9053a479a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT fk_rails_9053a479a7 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_answers fk_rails_9310a46d9c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answers
    ADD CONSTRAINT fk_rails_9310a46d9c FOREIGN KEY (archived_by_id) REFERENCES public.users(id);


--
-- Name: tickets fk_rails_939b990649; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_939b990649 FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_category_translations fk_rails_9498fb4334; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_category_translations
    ADD CONSTRAINT fk_rails_9498fb4334 FOREIGN KEY (category_id) REFERENCES public.knowledge_base_categories(id) ON DELETE CASCADE;


--
-- Name: object_manager_attributes fk_rails_96414e774d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_manager_attributes
    ADD CONSTRAINT fk_rails_96414e774d FOREIGN KEY (object_lookup_id) REFERENCES public.object_lookups(id);


--
-- Name: pgp_keys fk_rails_96d40647cd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgp_keys
    ADD CONSTRAINT fk_rails_96d40647cd FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: templates fk_rails_989d730f4b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT fk_rails_989d730f4b FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: signatures fk_rails_997a237d5e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signatures
    ADD CONSTRAINT fk_rails_997a237d5e FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: postmaster_filters fk_rails_99ae723fc6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postmaster_filters
    ADD CONSTRAINT fk_rails_99ae723fc6 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: chat_agents fk_rails_99fffe7295; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_agents
    ADD CONSTRAINT fk_rails_99fffe7295 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: checklist_items fk_rails_9a8f4b4e17; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_items
    ADD CONSTRAINT fk_rails_9a8f4b4e17 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: chat_sessions fk_rails_9b5b542892; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT fk_rails_9b5b542892 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: roles_users fk_rails_9dada905f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles_users
    ADD CONSTRAINT fk_rails_9dada905f6 FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: checklist_template_items fk_rails_9efd208a07; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_template_items
    ADD CONSTRAINT fk_rails_9efd208a07 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: overviews fk_rails_a12668341b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overviews
    ADD CONSTRAINT fk_rails_a12668341b FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: ticket_time_accountings fk_rails_a206f3ed55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_time_accountings
    ADD CONSTRAINT fk_rails_a206f3ed55 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: overviews_users fk_rails_a217c968b0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overviews_users
    ADD CONSTRAINT fk_rails_a217c968b0 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: email_addresses fk_rails_a24ae390cf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses
    ADD CONSTRAINT fk_rails_a24ae390cf FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: links fk_rails_a578a39c28; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT fk_rails_a578a39c28 FOREIGN KEY (link_type_id) REFERENCES public.link_types(id);


--
-- Name: groups fk_rails_a828c3963d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_rails_a828c3963d FOREIGN KEY (email_address_id) REFERENCES public.email_addresses(id);


--
-- Name: organizations_users fk_rails_a89915da94; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_users
    ADD CONSTRAINT fk_rails_a89915da94 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_menu_items fk_rails_a97f5c9e10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_menu_items
    ADD CONSTRAINT fk_rails_a97f5c9e10 FOREIGN KEY (kb_locale_id) REFERENCES public.knowledge_base_locales(id) ON DELETE CASCADE;


--
-- Name: mentions fk_rails_ab5f91f9d0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT fk_rails_ab5f91f9d0 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: tokens fk_rails_ac8a5d0441; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT fk_rails_ac8a5d0441 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: object_manager_attributes fk_rails_acacd17a49; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_manager_attributes
    ADD CONSTRAINT fk_rails_acacd17a49 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: activity_streams fk_rails_add7ae94d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_streams
    ADD CONSTRAINT fk_rails_add7ae94d9 FOREIGN KEY (activity_stream_object_id) REFERENCES public.object_lookups(id);


--
-- Name: chat_messages fk_rails_af8ea0a844; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT fk_rails_af8ea0a844 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: roles fk_rails_b41292c88f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT fk_rails_b41292c88f FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: checklist_template_items fk_rails_b49a8a3eda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_template_items
    ADD CONSTRAINT fk_rails_b49a8a3eda FOREIGN KEY (checklist_template_id) REFERENCES public.checklist_templates(id);


--
-- Name: oauth_access_grants fk_rails_b4b53e07b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_b4b53e07b8 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: histories fk_rails_b522a94d99; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.histories
    ADD CONSTRAINT fk_rails_b522a94d99 FOREIGN KEY (history_attribute_id) REFERENCES public.history_attributes(id);


--
-- Name: http_logs fk_rails_b5bedd0284; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.http_logs
    ADD CONSTRAINT fk_rails_b5bedd0284 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: tickets fk_rails_b62b455ecb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_b62b455ecb FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: users fk_rails_b8d57d3c5d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_b8d57d3c5d FOREIGN KEY (out_of_office_replacement_id) REFERENCES public.users(id);


--
-- Name: online_notifications fk_rails_bc45d196c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_notifications
    ADD CONSTRAINT fk_rails_bc45d196c5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: report_profiles_roles fk_rails_bd2c9e07a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_profiles_roles
    ADD CONSTRAINT fk_rails_bd2c9e07a3 FOREIGN KEY (profile_id) REFERENCES public.report_profiles(id);


--
-- Name: groups fk_rails_be49f097d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_rails_be49f097d1 FOREIGN KEY (parent_id) REFERENCES public.groups(id);


--
-- Name: knowledge_base_answers fk_rails_bf50cfe263; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answers
    ADD CONSTRAINT fk_rails_bf50cfe263 FOREIGN KEY (category_id) REFERENCES public.knowledge_base_categories(id);


--
-- Name: report_profiles fk_rails_c0dbdacc53; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_profiles
    ADD CONSTRAINT fk_rails_c0dbdacc53 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: recent_views fk_rails_c0fa5dd51d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recent_views
    ADD CONSTRAINT fk_rails_c0fa5dd51d FOREIGN KEY (recent_view_object_id) REFERENCES public.object_lookups(id);


--
-- Name: overviews_groups fk_rails_c1fad4d2c4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overviews_groups
    ADD CONSTRAINT fk_rails_c1fad4d2c4 FOREIGN KEY (overview_id) REFERENCES public.overviews(id);


--
-- Name: ticket_articles fk_rails_c2dbb9e7aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_articles
    ADD CONSTRAINT fk_rails_c2dbb9e7aa FOREIGN KEY (origin_by_id) REFERENCES public.users(id);


--
-- Name: ticket_articles fk_rails_c3aaa7b29b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_articles
    ADD CONSTRAINT fk_rails_c3aaa7b29b FOREIGN KEY (type_id) REFERENCES public.ticket_article_types(id);


--
-- Name: jobs fk_rails_c4f56411f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT fk_rails_c4f56411f8 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: checklists fk_rails_c5c7fe370e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklists
    ADD CONSTRAINT fk_rails_c5c7fe370e FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: checklists fk_rails_c89d59efd3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklists
    ADD CONSTRAINT fk_rails_c89d59efd3 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: chats fk_rails_cb3fe7fa69; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT fk_rails_cb3fe7fa69 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: roles_groups fk_rails_ccd9830e29; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles_groups
    ADD CONSTRAINT fk_rails_ccd9830e29 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: ticket_daily_event_locks fk_rails_cde57857f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_daily_event_locks
    ADD CONSTRAINT fk_rails_cde57857f0 FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: mentions fk_rails_cf60468410; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT fk_rails_cf60468410 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: chat_agents fk_rails_d009868f7d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_agents
    ADD CONSTRAINT fk_rails_d009868f7d FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: overviews_roles fk_rails_d0e00a0e5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overviews_roles
    ADD CONSTRAINT fk_rails_d0e00a0e5c FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: ticket_priorities fk_rails_d43af6872e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_priorities
    ADD CONSTRAINT fk_rails_d43af6872e FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: ai_analytics_usages fk_rails_d4ddfa6d74; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_analytics_usages
    ADD CONSTRAINT fk_rails_d4ddfa6d74 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: recent_closes fk_rails_d640edce33; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recent_closes
    ADD CONSTRAINT fk_rails_d640edce33 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: translations fk_rails_d6e6d9635d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translations
    ADD CONSTRAINT fk_rails_d6e6d9635d FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_d7b9ff90af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_d7b9ff90af FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: chat_sessions fk_rails_dab338cf4e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT fk_rails_dab338cf4e FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: stores fk_rails_de6a5f3de1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT fk_rails_de6a5f3de1 FOREIGN KEY (store_object_id) REFERENCES public.store_objects(id);


--
-- Name: ticket_time_accountings fk_rails_e065af46d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_time_accountings
    ADD CONSTRAINT fk_rails_e065af46d9 FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: checklist_templates fk_rails_e06adf803d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT fk_rails_e06adf803d FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: schedulers fk_rails_e0c99c2069; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedulers
    ADD CONSTRAINT fk_rails_e0c99c2069 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: tags fk_rails_e18a92e0c6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT fk_rails_e18a92e0c6 FOREIGN KEY (tag_object_id) REFERENCES public.tag_objects(id);


--
-- Name: roles_users fk_rails_e2a7142459; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles_users
    ADD CONSTRAINT fk_rails_e2a7142459 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_answer_translations fk_rails_e55f86d7ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answer_translations
    ADD CONSTRAINT fk_rails_e55f86d7ec FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: user_devices fk_rails_e700a96826; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT fk_rails_e700a96826 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ai_text_tools fk_rails_e703fac5a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_text_tools
    ADD CONSTRAINT fk_rails_e703fac5a0 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: object_manager_attributes fk_rails_e812039563; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object_manager_attributes
    ADD CONSTRAINT fk_rails_e812039563 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: roles fk_rails_e85422db7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT fk_rails_e85422db7e FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: ticket_time_accountings fk_rails_e9be901ba1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_time_accountings
    ADD CONSTRAINT fk_rails_e9be901ba1 FOREIGN KEY (type_id) REFERENCES public.ticket_time_accounting_types(id);


--
-- Name: knowledge_base_answer_translations fk_rails_ea33e2edf8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_answer_translations
    ADD CONSTRAINT fk_rails_ea33e2edf8 FOREIGN KEY (answer_id) REFERENCES public.knowledge_base_answers(id) ON DELETE CASCADE;


--
-- Name: groups_macros fk_rails_eb067eb8bf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_macros
    ADD CONSTRAINT fk_rails_eb067eb8bf FOREIGN KEY (macro_id) REFERENCES public.macros(id);


--
-- Name: tags fk_rails_ebb54809f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT fk_rails_ebb54809f6 FOREIGN KEY (tag_item_id) REFERENCES public.tag_items(id);


--
-- Name: tickets fk_rails_ebb661298a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_ebb661298a FOREIGN KEY (checklist_id) REFERENCES public.checklists(id);


--
-- Name: ai_text_tools fk_rails_ed7bebd834; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_text_tools
    ADD CONSTRAINT fk_rails_ed7bebd834 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: organizations fk_rails_edec76c076; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT fk_rails_edec76c076 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: tickets fk_rails_edf0f77848; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_edf0f77848 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: online_notifications fk_rails_ee155e3c0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_notifications
    ADD CONSTRAINT fk_rails_ee155e3c0c FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: cti_caller_ids fk_rails_f03ef195fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cti_caller_ids
    ADD CONSTRAINT fk_rails_f03ef195fa FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: overviews_users fk_rails_f121b4257f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overviews_users
    ADD CONSTRAINT fk_rails_f121b4257f FOREIGN KEY (overview_id) REFERENCES public.overviews(id);


--
-- Name: channels fk_rails_f1fc2a34ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT fk_rails_f1fc2a34ff FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: tickets fk_rails_f39559d6d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_f39559d6d6 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: taskbars fk_rails_f3c54fdb6d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taskbars
    ADD CONSTRAINT fk_rails_f3c54fdb6d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ticket_article_senders fk_rails_f5ba9a2f30; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_article_senders
    ADD CONSTRAINT fk_rails_f5ba9a2f30 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: ai_analytics_runs fk_rails_f5f9565172; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_analytics_runs
    ADD CONSTRAINT fk_rails_f5f9565172 FOREIGN KEY (locale_id) REFERENCES public.locales(id);


--
-- Name: tickets fk_rails_f694a04b71; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_f694a04b71 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: pgp_keys fk_rails_f8cb74123e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgp_keys
    ADD CONSTRAINT fk_rails_f8cb74123e FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: knowledge_base_category_translations fk_rails_f90418ca0f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_base_category_translations
    ADD CONSTRAINT fk_rails_f90418ca0f FOREIGN KEY (kb_locale_id) REFERENCES public.knowledge_base_locales(id);


--
-- Name: ai_stored_results fk_rails_f9567bd731; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_stored_results
    ADD CONSTRAINT fk_rails_f9567bd731 FOREIGN KEY (ai_analytics_run_id) REFERENCES public.ai_analytics_runs(id);


--
-- Name: overviews_roles fk_rails_fa1b820fe5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overviews_roles
    ADD CONSTRAINT fk_rails_fa1b820fe5 FOREIGN KEY (overview_id) REFERENCES public.overviews(id);


--
-- Name: recent_views fk_rails_fa835b7d0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recent_views
    ADD CONSTRAINT fk_rails_fa835b7d0c FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: tickets fk_rails_fc553dc329; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_fc553dc329 FOREIGN KEY (state_id) REFERENCES public.ticket_states(id);


--
-- PostgreSQL database dump complete
--


