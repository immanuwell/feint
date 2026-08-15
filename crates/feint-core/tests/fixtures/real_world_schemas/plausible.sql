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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: billing_interval; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.billing_interval AS ENUM (
    'monthly',
    'yearly'
);


--
-- Name: oban_job_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oban_job_state AS ENUM (
    'available',
    'scheduled',
    'executing',
    'retryable',
    'completed',
    'discarded',
    'cancelled'
);


--
-- Name: segment_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.segment_type AS ENUM (
    'personal',
    'site'
);


--
-- Name: site_membership_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.site_membership_role AS ENUM (
    'owner',
    'admin',
    'viewer'
);


--
-- Name: check_domain(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_domain() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM sites
     WHERE (NEW.domain = domain_changed_from AND NEW.id != id)
     OR (OLD IS NULL AND NEW.domain_changed_from = domain)
  ) THEN
    RAISE unique_violation USING CONSTRAINT = 'domain_change_disallowed';
  END IF;
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_keys (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    key_prefix character varying(255) NOT NULL,
    key_hash character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    scopes text[] NOT NULL,
    hourly_request_limit integer DEFAULT 1000 NOT NULL,
    team_id bigint
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_keys_id_seq OWNED BY public.api_keys.id;


--
-- Name: check_stats_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.check_stats_emails (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    "timestamp" timestamp(0) without time zone
);


--
-- Name: check_stats_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.check_stats_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: check_stats_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.check_stats_emails_id_seq OWNED BY public.check_stats_emails.id;


--
-- Name: create_site_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.create_site_emails (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    "timestamp" timestamp(0) without time zone
);


--
-- Name: create_site_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.create_site_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: create_site_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.create_site_emails_id_seq OWNED BY public.create_site_emails.id;


--
-- Name: email_activation_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_activation_codes (
    id bigint NOT NULL,
    code text NOT NULL,
    user_id bigint NOT NULL,
    issued_at timestamp(0) without time zone NOT NULL
);


--
-- Name: email_activation_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_activation_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_activation_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_activation_codes_id_seq OWNED BY public.email_activation_codes.id;


--
-- Name: email_verification_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_verification_codes (
    code integer NOT NULL,
    user_id bigint,
    issued_at timestamp(0) without time zone
);


--
-- Name: enterprise_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enterprise_plans (
    id bigint NOT NULL,
    user_id bigint,
    paddle_plan_id character varying(255) NOT NULL,
    billing_interval public.billing_interval NOT NULL,
    monthly_pageview_limit integer NOT NULL,
    hourly_api_request_limit integer NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    site_limit integer NOT NULL,
    team_member_limit integer DEFAULT '-1'::integer NOT NULL,
    features character varying(255)[] DEFAULT ARRAY['props'::character varying, 'stats_api'::character varying] NOT NULL,
    team_id bigint
);


--
-- Name: enterprise_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enterprise_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enterprise_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enterprise_plans_id_seq OWNED BY public.enterprise_plans.id;


--
-- Name: feedback_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedback_emails (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    "timestamp" timestamp(0) without time zone NOT NULL
);


--
-- Name: feedback_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feedback_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedback_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feedback_emails_id_seq OWNED BY public.feedback_emails.id;


--
-- Name: fun_with_flags_toggles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fun_with_flags_toggles (
    id bigint NOT NULL,
    flag_name character varying(255) NOT NULL,
    gate_type character varying(255) NOT NULL,
    target character varying(255) NOT NULL,
    enabled boolean NOT NULL
);


--
-- Name: fun_with_flags_toggles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fun_with_flags_toggles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fun_with_flags_toggles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fun_with_flags_toggles_id_seq OWNED BY public.fun_with_flags_toggles.id;


--
-- Name: funnel_steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funnel_steps (
    id bigint NOT NULL,
    goal_id bigint NOT NULL,
    funnel_id bigint NOT NULL,
    step_order integer NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: funnel_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.funnel_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funnel_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.funnel_steps_id_seq OWNED BY public.funnel_steps.id;


--
-- Name: funnels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funnels (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    site_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: funnels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.funnels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funnels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.funnels_id_seq OWNED BY public.funnels.id;


--
-- Name: goals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.goals (
    id bigint NOT NULL,
    event_name text,
    page_path text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    site_id bigint NOT NULL,
    currency character varying(3),
    display_name text NOT NULL,
    scroll_threshold smallint DEFAULT '-1'::integer NOT NULL,
    custom_props jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: goals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.goals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: goals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.goals_id_seq OWNED BY public.goals.id;


--
-- Name: google_auth; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.google_auth (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    email character varying(255) NOT NULL,
    refresh_token text NOT NULL,
    access_token text NOT NULL,
    expires timestamp(0) without time zone NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    site_id bigint NOT NULL,
    property text
);


--
-- Name: google_auth_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.google_auth_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: google_auth_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.google_auth_id_seq OWNED BY public.google_auth.id;


--
-- Name: guest_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guest_invitations (
    id bigint NOT NULL,
    role character varying(255) NOT NULL,
    site_id bigint NOT NULL,
    team_invitation_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    invitation_id character varying(255) NOT NULL
);


--
-- Name: guest_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.guest_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guest_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.guest_invitations_id_seq OWNED BY public.guest_invitations.id;


--
-- Name: guest_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guest_memberships (
    id bigint NOT NULL,
    role character varying(255) NOT NULL,
    team_membership_id bigint NOT NULL,
    site_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: guest_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.guest_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guest_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.guest_memberships_id_seq OWNED BY public.guest_memberships.id;


--
-- Name: intro_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.intro_emails (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    "timestamp" timestamp(0) without time zone
);


--
-- Name: intro_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.intro_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intro_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.intro_emails_id_seq OWNED BY public.intro_emails.id;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitations (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    site_id bigint NOT NULL,
    inviter_id bigint NOT NULL,
    role public.site_membership_role NOT NULL,
    invitation_id character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invitations_id_seq OWNED BY public.invitations.id;


--
-- Name: monthly_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monthly_reports (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    recipients public.citext[] DEFAULT ARRAY[]::public.citext[] NOT NULL
);


--
-- Name: monthly_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monthly_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monthly_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monthly_reports_id_seq OWNED BY public.monthly_reports.id;


--
-- Name: oban_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oban_jobs (
    id bigint NOT NULL,
    state public.oban_job_state DEFAULT 'available'::public.oban_job_state NOT NULL,
    queue text DEFAULT 'default'::text NOT NULL,
    worker text NOT NULL,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    errors jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    attempt integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 20 NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    scheduled_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    attempted_at timestamp without time zone,
    completed_at timestamp without time zone,
    attempted_by text[],
    discarded_at timestamp without time zone,
    priority integer DEFAULT 0 NOT NULL,
    tags text[] DEFAULT ARRAY[]::text[],
    meta jsonb DEFAULT '{}'::jsonb,
    cancelled_at timestamp without time zone,
    CONSTRAINT attempt_range CHECK (((attempt >= 0) AND (attempt <= max_attempts))),
    CONSTRAINT positive_max_attempts CHECK ((max_attempts > 0)),
    CONSTRAINT queue_length CHECK (((char_length(queue) > 0) AND (char_length(queue) < 128))),
    CONSTRAINT worker_length CHECK (((char_length(worker) > 0) AND (char_length(worker) < 128)))
);


--
-- Name: TABLE oban_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.oban_jobs IS '13';


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oban_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oban_jobs_id_seq OWNED BY public.oban_jobs.id;


--
-- Name: oban_peers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.oban_peers (
    name text NOT NULL,
    node text NOT NULL,
    started_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: plugins_api_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plugins_api_tokens (
    id uuid NOT NULL,
    site_id bigint NOT NULL,
    token_hash bytea NOT NULL,
    hint character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    last_used_at timestamp(0) without time zone
);


--
-- Name: salts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.salts (
    id bigint NOT NULL,
    salt bytea NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: salts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.salts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: salts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.salts_id_seq OWNED BY public.salts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: segments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.segments (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    type public.segment_type DEFAULT 'personal'::public.segment_type NOT NULL,
    segment_data jsonb NOT NULL,
    site_id bigint NOT NULL,
    owner_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: segments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.segments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: segments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.segments_id_seq OWNED BY public.segments.id;


--
-- Name: sent_accept_traffic_until_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sent_accept_traffic_until_notifications (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    sent_on date NOT NULL
);


--
-- Name: sent_accept_traffic_until_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sent_accept_traffic_until_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sent_accept_traffic_until_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sent_accept_traffic_until_notifications_id_seq OWNED BY public.sent_accept_traffic_until_notifications.id;


--
-- Name: sent_monthly_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sent_monthly_reports (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    year integer NOT NULL,
    month integer NOT NULL,
    "timestamp" timestamp(0) without time zone
);


--
-- Name: sent_monthly_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sent_monthly_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sent_monthly_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sent_monthly_reports_id_seq OWNED BY public.sent_monthly_reports.id;


--
-- Name: sent_renewal_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sent_renewal_notifications (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    "timestamp" timestamp(0) without time zone
);


--
-- Name: sent_renewal_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sent_renewal_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sent_renewal_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sent_renewal_notifications_id_seq OWNED BY public.sent_renewal_notifications.id;


--
-- Name: sent_weekly_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sent_weekly_reports (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    year integer,
    week integer,
    "timestamp" timestamp(0) without time zone
);


--
-- Name: sent_weekly_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sent_weekly_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sent_weekly_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sent_weekly_reports_id_seq OWNED BY public.sent_weekly_reports.id;


--
-- Name: setup_help_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.setup_help_emails (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    "timestamp" timestamp(0) without time zone
);


--
-- Name: setup_help_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.setup_help_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: setup_help_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.setup_help_emails_id_seq OWNED BY public.setup_help_emails.id;


--
-- Name: setup_success_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.setup_success_emails (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    "timestamp" timestamp(0) without time zone
);


--
-- Name: setup_success_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.setup_success_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: setup_success_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.setup_success_emails_id_seq OWNED BY public.setup_success_emails.id;


--
-- Name: shared_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shared_links (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    slug character varying(255) NOT NULL,
    password_hash character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    name character varying(255) NOT NULL,
    segment_id bigint
);


--
-- Name: shared_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shared_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shared_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shared_links_id_seq OWNED BY public.shared_links.id;


--
-- Name: shield_rules_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shield_rules_country (
    id uuid NOT NULL,
    site_id bigint NOT NULL,
    country_code text NOT NULL,
    action character varying(255) DEFAULT 'deny'::character varying NOT NULL,
    added_by character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: shield_rules_hostname; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shield_rules_hostname (
    id uuid NOT NULL,
    site_id bigint NOT NULL,
    hostname text NOT NULL,
    hostname_pattern text NOT NULL,
    action character varying(255) DEFAULT 'allow'::character varying NOT NULL,
    added_by character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: shield_rules_ip; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shield_rules_ip (
    id uuid NOT NULL,
    site_id bigint NOT NULL,
    inet inet,
    action character varying(255) DEFAULT 'deny'::character varying NOT NULL,
    description character varying(255),
    added_by character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: shield_rules_page; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shield_rules_page (
    id uuid NOT NULL,
    site_id bigint NOT NULL,
    page_path text NOT NULL,
    page_path_pattern text NOT NULL,
    action character varying(255) DEFAULT 'deny'::character varying NOT NULL,
    added_by character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: site_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_imports (
    id bigint NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    source character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    site_id bigint NOT NULL,
    imported_by_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    legacy boolean DEFAULT true NOT NULL,
    label character varying(255),
    has_scroll_depth boolean DEFAULT false NOT NULL
);


--
-- Name: site_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_imports_id_seq OWNED BY public.site_imports.id;


--
-- Name: site_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_memberships (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    role public.site_membership_role DEFAULT 'owner'::public.site_membership_role NOT NULL
);


--
-- Name: site_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_memberships_id_seq OWNED BY public.site_memberships.id;


--
-- Name: site_user_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_user_preferences (
    id bigint NOT NULL,
    pinned_at timestamp(0) without time zone,
    user_id bigint NOT NULL,
    site_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: site_user_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_user_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_user_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_user_preferences_id_seq OWNED BY public.site_user_preferences.id;


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id bigint NOT NULL,
    domain character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    timezone character varying(255) NOT NULL,
    public boolean DEFAULT false NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    has_stats boolean DEFAULT false NOT NULL,
    imported_data jsonb,
    stats_start_date date,
    ingest_rate_limit_scale_seconds integer DEFAULT 60 NOT NULL,
    ingest_rate_limit_threshold integer,
    native_stats_start_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    domain_changed_from character varying(255),
    domain_changed_at timestamp(0) without time zone,
    allowed_event_props character varying(300)[],
    conversions_enabled boolean DEFAULT true NOT NULL,
    funnels_enabled boolean DEFAULT true NOT NULL,
    props_enabled boolean DEFAULT true NOT NULL,
    accept_traffic_until timestamp(0) without time zone,
    installation_meta jsonb,
    team_id bigint,
    legacy_time_on_page_cutoff date DEFAULT to_date('1970-01-01'::text, 'YYYY-MM-DD'::text),
    consolidated boolean DEFAULT false NOT NULL
);


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sites_id_seq OWNED BY public.sites.id;


--
-- Name: spike_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spike_notifications (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    threshold integer NOT NULL,
    last_sent timestamp(0) without time zone,
    recipients public.citext[] DEFAULT ARRAY[]::public.citext[] NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    type character varying(255) DEFAULT 'spike'::character varying
);


--
-- Name: spike_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spike_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spike_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spike_notifications_id_seq OWNED BY public.spike_notifications.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id bigint NOT NULL,
    paddle_subscription_id character varying(255),
    paddle_plan_id character varying(255) NOT NULL,
    user_id bigint,
    update_url text,
    cancel_url text,
    status character varying(255) NOT NULL,
    next_bill_amount character varying(255) NOT NULL,
    next_bill_date date,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    last_bill_date date,
    currency_code character varying(255) NOT NULL,
    team_id bigint
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: team_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_invitations (
    id bigint NOT NULL,
    invitation_id character varying(255) NOT NULL,
    email public.citext,
    role character varying(255) NOT NULL,
    inviter_id bigint NOT NULL,
    team_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: team_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_invitations_id_seq OWNED BY public.team_invitations.id;


--
-- Name: team_membership_user_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_membership_user_preferences (
    id bigint NOT NULL,
    consolidated_view_cta_dismissed boolean DEFAULT false,
    team_membership_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: team_membership_user_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_membership_user_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_membership_user_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_membership_user_preferences_id_seq OWNED BY public.team_membership_user_preferences.id;


--
-- Name: team_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_memberships (
    id bigint NOT NULL,
    role character varying(255) NOT NULL,
    user_id bigint NOT NULL,
    team_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    is_autocreated boolean DEFAULT false NOT NULL
);


--
-- Name: team_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_memberships_id_seq OWNED BY public.team_memberships.id;


--
-- Name: team_site_transfers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_site_transfers (
    id bigint NOT NULL,
    transfer_id character varying(255) NOT NULL,
    email public.citext,
    transfer_guests boolean DEFAULT true NOT NULL,
    site_id bigint NOT NULL,
    destination_team_id bigint,
    initiator_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: team_site_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_site_transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_site_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_site_transfers_id_seq OWNED BY public.team_site_transfers.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    trial_expiry_date date,
    accept_traffic_until date,
    allow_next_upgrade_override boolean DEFAULT false NOT NULL,
    grace_period jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    setup_complete boolean DEFAULT false NOT NULL,
    setup_at timestamp(0) without time zone,
    identifier uuid DEFAULT gen_random_uuid() NOT NULL,
    notes text,
    hourly_api_request_limit integer DEFAULT 600 NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    locked_by_admin boolean DEFAULT false NOT NULL,
    policy jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: totp_recovery_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.totp_recovery_codes (
    id bigint NOT NULL,
    code_digest bytea NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: totp_recovery_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.totp_recovery_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: totp_recovery_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.totp_recovery_codes_id_seq OWNED BY public.totp_recovery_codes.id;


--
-- Name: tracker_script_configuration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tracker_script_configuration (
    id character varying(255) NOT NULL,
    installation_type character varying(255),
    track_404_pages boolean DEFAULT false,
    hash_based_routing boolean DEFAULT false,
    outbound_links boolean DEFAULT false,
    file_downloads boolean DEFAULT false,
    revenue_tracking boolean DEFAULT false,
    tagged_events boolean DEFAULT false,
    form_submissions boolean DEFAULT false,
    pageview_props boolean DEFAULT false,
    site_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token bytea NOT NULL,
    device character varying(255) NOT NULL,
    last_used_at timestamp(0) without time zone NOT NULL,
    timeout_at timestamp(0) without time zone NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: user_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_sessions_id_seq OWNED BY public.user_sessions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    name character varying(255),
    last_seen timestamp(0) without time zone DEFAULT now(),
    password_hash character varying(255),
    trial_expiry_date date,
    email_verified boolean DEFAULT false NOT NULL,
    theme character varying(255) DEFAULT 'system'::character varying,
    grace_period jsonb,
    previous_email public.citext,
    totp_secret bytea,
    totp_enabled boolean DEFAULT false NOT NULL,
    totp_last_used_at timestamp(0) without time zone,
    allow_next_upgrade_override boolean DEFAULT false NOT NULL,
    totp_token character varying(255),
    accept_traffic_until date,
    notes text,
    last_team_identifier bytea
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
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
-- Name: weekly_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weekly_reports (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    recipients public.citext[] DEFAULT ARRAY[]::public.citext[] NOT NULL
);


--
-- Name: weekly_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.weekly_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: weekly_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.weekly_reports_id_seq OWNED BY public.weekly_reports.id;


--
-- Name: api_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys ALTER COLUMN id SET DEFAULT nextval('public.api_keys_id_seq'::regclass);


--
-- Name: check_stats_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_stats_emails ALTER COLUMN id SET DEFAULT nextval('public.check_stats_emails_id_seq'::regclass);


--
-- Name: create_site_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.create_site_emails ALTER COLUMN id SET DEFAULT nextval('public.create_site_emails_id_seq'::regclass);


--
-- Name: email_activation_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_activation_codes ALTER COLUMN id SET DEFAULT nextval('public.email_activation_codes_id_seq'::regclass);


--
-- Name: enterprise_plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enterprise_plans ALTER COLUMN id SET DEFAULT nextval('public.enterprise_plans_id_seq'::regclass);


--
-- Name: feedback_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedback_emails ALTER COLUMN id SET DEFAULT nextval('public.feedback_emails_id_seq'::regclass);


--
-- Name: fun_with_flags_toggles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fun_with_flags_toggles ALTER COLUMN id SET DEFAULT nextval('public.fun_with_flags_toggles_id_seq'::regclass);


--
-- Name: funnel_steps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funnel_steps ALTER COLUMN id SET DEFAULT nextval('public.funnel_steps_id_seq'::regclass);


--
-- Name: funnels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funnels ALTER COLUMN id SET DEFAULT nextval('public.funnels_id_seq'::regclass);


--
-- Name: goals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals ALTER COLUMN id SET DEFAULT nextval('public.goals_id_seq'::regclass);


--
-- Name: google_auth id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_auth ALTER COLUMN id SET DEFAULT nextval('public.google_auth_id_seq'::regclass);


--
-- Name: guest_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_invitations ALTER COLUMN id SET DEFAULT nextval('public.guest_invitations_id_seq'::regclass);


--
-- Name: guest_memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_memberships ALTER COLUMN id SET DEFAULT nextval('public.guest_memberships_id_seq'::regclass);


--
-- Name: intro_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intro_emails ALTER COLUMN id SET DEFAULT nextval('public.intro_emails_id_seq'::regclass);


--
-- Name: invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations ALTER COLUMN id SET DEFAULT nextval('public.invitations_id_seq'::regclass);


--
-- Name: monthly_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_reports ALTER COLUMN id SET DEFAULT nextval('public.monthly_reports_id_seq'::regclass);


--
-- Name: oban_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs ALTER COLUMN id SET DEFAULT nextval('public.oban_jobs_id_seq'::regclass);


--
-- Name: salts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salts ALTER COLUMN id SET DEFAULT nextval('public.salts_id_seq'::regclass);


--
-- Name: segments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.segments ALTER COLUMN id SET DEFAULT nextval('public.segments_id_seq'::regclass);


--
-- Name: sent_accept_traffic_until_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_accept_traffic_until_notifications ALTER COLUMN id SET DEFAULT nextval('public.sent_accept_traffic_until_notifications_id_seq'::regclass);


--
-- Name: sent_monthly_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_monthly_reports ALTER COLUMN id SET DEFAULT nextval('public.sent_monthly_reports_id_seq'::regclass);


--
-- Name: sent_renewal_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_renewal_notifications ALTER COLUMN id SET DEFAULT nextval('public.sent_renewal_notifications_id_seq'::regclass);


--
-- Name: sent_weekly_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_weekly_reports ALTER COLUMN id SET DEFAULT nextval('public.sent_weekly_reports_id_seq'::regclass);


--
-- Name: setup_help_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.setup_help_emails ALTER COLUMN id SET DEFAULT nextval('public.setup_help_emails_id_seq'::regclass);


--
-- Name: setup_success_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.setup_success_emails ALTER COLUMN id SET DEFAULT nextval('public.setup_success_emails_id_seq'::regclass);


--
-- Name: shared_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_links ALTER COLUMN id SET DEFAULT nextval('public.shared_links_id_seq'::regclass);


--
-- Name: site_imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_imports ALTER COLUMN id SET DEFAULT nextval('public.site_imports_id_seq'::regclass);


--
-- Name: site_memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_memberships ALTER COLUMN id SET DEFAULT nextval('public.site_memberships_id_seq'::regclass);


--
-- Name: site_user_preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_user_preferences ALTER COLUMN id SET DEFAULT nextval('public.site_user_preferences_id_seq'::regclass);


--
-- Name: sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites ALTER COLUMN id SET DEFAULT nextval('public.sites_id_seq'::regclass);


--
-- Name: spike_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spike_notifications ALTER COLUMN id SET DEFAULT nextval('public.spike_notifications_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: team_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invitations ALTER COLUMN id SET DEFAULT nextval('public.team_invitations_id_seq'::regclass);


--
-- Name: team_membership_user_preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_membership_user_preferences ALTER COLUMN id SET DEFAULT nextval('public.team_membership_user_preferences_id_seq'::regclass);


--
-- Name: team_memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_memberships ALTER COLUMN id SET DEFAULT nextval('public.team_memberships_id_seq'::regclass);


--
-- Name: team_site_transfers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_site_transfers ALTER COLUMN id SET DEFAULT nextval('public.team_site_transfers_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: totp_recovery_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.totp_recovery_codes ALTER COLUMN id SET DEFAULT nextval('public.totp_recovery_codes_id_seq'::regclass);


--
-- Name: user_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions ALTER COLUMN id SET DEFAULT nextval('public.user_sessions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: weekly_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weekly_reports ALTER COLUMN id SET DEFAULT nextval('public.weekly_reports_id_seq'::regclass);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: goals check_event_name_or_page_path; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.goals
    ADD CONSTRAINT check_event_name_or_page_path CHECK ((((event_name IS NOT NULL) AND (page_path IS NULL)) OR ((event_name IS NULL) AND (page_path IS NOT NULL)))) NOT VALID;


--
-- Name: check_stats_emails check_stats_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_stats_emails
    ADD CONSTRAINT check_stats_emails_pkey PRIMARY KEY (id);


--
-- Name: create_site_emails create_site_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.create_site_emails
    ADD CONSTRAINT create_site_emails_pkey PRIMARY KEY (id);


--
-- Name: email_activation_codes email_activation_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_activation_codes
    ADD CONSTRAINT email_activation_codes_pkey PRIMARY KEY (id);


--
-- Name: enterprise_plans enterprise_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enterprise_plans
    ADD CONSTRAINT enterprise_plans_pkey PRIMARY KEY (id);


--
-- Name: feedback_emails feedback_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedback_emails
    ADD CONSTRAINT feedback_emails_pkey PRIMARY KEY (id);


--
-- Name: fun_with_flags_toggles fun_with_flags_toggles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fun_with_flags_toggles
    ADD CONSTRAINT fun_with_flags_toggles_pkey PRIMARY KEY (id);


--
-- Name: funnel_steps funnel_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funnel_steps
    ADD CONSTRAINT funnel_steps_pkey PRIMARY KEY (id);


--
-- Name: funnels funnels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funnels
    ADD CONSTRAINT funnels_pkey PRIMARY KEY (id);


--
-- Name: goals goals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_pkey PRIMARY KEY (id);


--
-- Name: google_auth google_auth_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_auth
    ADD CONSTRAINT google_auth_pkey PRIMARY KEY (id);


--
-- Name: guest_invitations guest_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_invitations
    ADD CONSTRAINT guest_invitations_pkey PRIMARY KEY (id);


--
-- Name: guest_memberships guest_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_memberships
    ADD CONSTRAINT guest_memberships_pkey PRIMARY KEY (id);


--
-- Name: intro_emails intro_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intro_emails
    ADD CONSTRAINT intro_emails_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: monthly_reports monthly_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_reports
    ADD CONSTRAINT monthly_reports_pkey PRIMARY KEY (id);


--
-- Name: oban_jobs non_negative_priority; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.oban_jobs
    ADD CONSTRAINT non_negative_priority CHECK ((priority >= 0)) NOT VALID;


--
-- Name: oban_jobs oban_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs
    ADD CONSTRAINT oban_jobs_pkey PRIMARY KEY (id);


--
-- Name: oban_peers oban_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_peers
    ADD CONSTRAINT oban_peers_pkey PRIMARY KEY (name);


--
-- Name: plugins_api_tokens plugins_api_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugins_api_tokens
    ADD CONSTRAINT plugins_api_tokens_pkey PRIMARY KEY (id);


--
-- Name: salts salts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salts
    ADD CONSTRAINT salts_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: segments segments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.segments
    ADD CONSTRAINT segments_pkey PRIMARY KEY (id);


--
-- Name: sent_accept_traffic_until_notifications sent_accept_traffic_until_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_accept_traffic_until_notifications
    ADD CONSTRAINT sent_accept_traffic_until_notifications_pkey PRIMARY KEY (id);


--
-- Name: sent_monthly_reports sent_monthly_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_monthly_reports
    ADD CONSTRAINT sent_monthly_reports_pkey PRIMARY KEY (id);


--
-- Name: sent_renewal_notifications sent_renewal_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_renewal_notifications
    ADD CONSTRAINT sent_renewal_notifications_pkey PRIMARY KEY (id);


--
-- Name: sent_weekly_reports sent_weekly_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_weekly_reports
    ADD CONSTRAINT sent_weekly_reports_pkey PRIMARY KEY (id);


--
-- Name: setup_help_emails setup_help_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.setup_help_emails
    ADD CONSTRAINT setup_help_emails_pkey PRIMARY KEY (id);


--
-- Name: setup_success_emails setup_success_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.setup_success_emails
    ADD CONSTRAINT setup_success_emails_pkey PRIMARY KEY (id);


--
-- Name: shared_links shared_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_links
    ADD CONSTRAINT shared_links_pkey PRIMARY KEY (id);


--
-- Name: shield_rules_country shield_rules_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shield_rules_country
    ADD CONSTRAINT shield_rules_country_pkey PRIMARY KEY (id);


--
-- Name: shield_rules_hostname shield_rules_hostname_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shield_rules_hostname
    ADD CONSTRAINT shield_rules_hostname_pkey PRIMARY KEY (id);


--
-- Name: shield_rules_ip shield_rules_ip_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shield_rules_ip
    ADD CONSTRAINT shield_rules_ip_pkey PRIMARY KEY (id);


--
-- Name: shield_rules_page shield_rules_page_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shield_rules_page
    ADD CONSTRAINT shield_rules_page_pkey PRIMARY KEY (id);


--
-- Name: site_imports site_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_imports
    ADD CONSTRAINT site_imports_pkey PRIMARY KEY (id);


--
-- Name: site_memberships site_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_memberships
    ADD CONSTRAINT site_memberships_pkey PRIMARY KEY (id);


--
-- Name: site_user_preferences site_user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_user_preferences
    ADD CONSTRAINT site_user_preferences_pkey PRIMARY KEY (id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: spike_notifications spike_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spike_notifications
    ADD CONSTRAINT spike_notifications_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: team_invitations team_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_pkey PRIMARY KEY (id);


--
-- Name: team_membership_user_preferences team_membership_user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_membership_user_preferences
    ADD CONSTRAINT team_membership_user_preferences_pkey PRIMARY KEY (id);


--
-- Name: team_memberships team_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_memberships
    ADD CONSTRAINT team_memberships_pkey PRIMARY KEY (id);


--
-- Name: team_site_transfers team_site_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_site_transfers
    ADD CONSTRAINT team_site_transfers_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: totp_recovery_codes totp_recovery_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.totp_recovery_codes
    ADD CONSTRAINT totp_recovery_codes_pkey PRIMARY KEY (id);


--
-- Name: tracker_script_configuration tracker_script_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracker_script_configuration
    ADD CONSTRAINT tracker_script_configuration_pkey PRIMARY KEY (id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: weekly_reports weekly_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weekly_reports
    ADD CONSTRAINT weekly_reports_pkey PRIMARY KEY (id);


--
-- Name: api_keys_key_hash_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX api_keys_key_hash_index ON public.api_keys USING btree (key_hash);


--
-- Name: api_keys_scopes_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX api_keys_scopes_index ON public.api_keys USING gin (scopes);


--
-- Name: api_keys_team_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX api_keys_team_id_index ON public.api_keys USING btree (team_id);


--
-- Name: api_keys_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX api_keys_user_id_index ON public.api_keys USING btree (user_id);


--
-- Name: check_stats_emails_user_id_timestamp_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX check_stats_emails_user_id_timestamp_index ON public.check_stats_emails USING btree (user_id, "timestamp");


--
-- Name: create_site_emails_user_id_timestamp_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX create_site_emails_user_id_timestamp_index ON public.create_site_emails USING btree (user_id, "timestamp");


--
-- Name: email_activation_codes_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX email_activation_codes_user_id_index ON public.email_activation_codes USING btree (user_id);


--
-- Name: enterprise_plans_team_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX enterprise_plans_team_id_index ON public.enterprise_plans USING btree (team_id);


--
-- Name: funnel_steps_goal_id_funnel_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX funnel_steps_goal_id_funnel_id_index ON public.funnel_steps USING btree (goal_id, funnel_id);


--
-- Name: funnels_name_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX funnels_name_site_id_index ON public.funnels USING btree (name, site_id);


--
-- Name: fwf_flag_name_gate_target_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX fwf_flag_name_gate_target_idx ON public.fun_with_flags_toggles USING btree (flag_name, gate_type, target);


--
-- Name: goals_display_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX goals_display_name_unique ON public.goals USING btree (site_id, display_name);


--
-- Name: goals_event_config_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX goals_event_config_unique ON public.goals USING btree (site_id, event_name, custom_props) WHERE (event_name IS NOT NULL);


--
-- Name: goals_pageview_config_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX goals_pageview_config_unique ON public.goals USING btree (site_id, page_path, scroll_threshold) WHERE (page_path IS NOT NULL);


--
-- Name: google_auth_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX google_auth_site_id_index ON public.google_auth USING btree (site_id);


--
-- Name: google_auth_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX google_auth_user_id_index ON public.google_auth USING btree (user_id);


--
-- Name: guest_invitations_invitation_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX guest_invitations_invitation_id_index ON public.guest_invitations USING btree (invitation_id);


--
-- Name: guest_invitations_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX guest_invitations_site_id_index ON public.guest_invitations USING btree (site_id);


--
-- Name: guest_invitations_team_invitation_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX guest_invitations_team_invitation_id_index ON public.guest_invitations USING btree (team_invitation_id);


--
-- Name: guest_invitations_team_invitation_id_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX guest_invitations_team_invitation_id_site_id_index ON public.guest_invitations USING btree (team_invitation_id, site_id);


--
-- Name: guest_memberships_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX guest_memberships_site_id_index ON public.guest_memberships USING btree (site_id);


--
-- Name: guest_memberships_team_membership_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX guest_memberships_team_membership_id_index ON public.guest_memberships USING btree (team_membership_id);


--
-- Name: guest_memberships_team_membership_id_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX guest_memberships_team_membership_id_site_id_index ON public.guest_memberships USING btree (team_membership_id, site_id);


--
-- Name: invitations_invitation_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invitations_invitation_id_index ON public.invitations USING btree (invitation_id);


--
-- Name: invitations_site_id_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invitations_site_id_email_index ON public.invitations USING btree (site_id, email);


--
-- Name: monthly_reports_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monthly_reports_site_id_index ON public.monthly_reports USING btree (site_id);


--
-- Name: oban_jobs_args_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_args_index ON public.oban_jobs USING gin (args);


--
-- Name: oban_jobs_meta_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_meta_index ON public.oban_jobs USING gin (meta);


--
-- Name: oban_jobs_state_cancelled_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_cancelled_at_index ON public.oban_jobs USING btree (state, cancelled_at);


--
-- Name: oban_jobs_state_discarded_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_discarded_at_index ON public.oban_jobs USING btree (state, discarded_at);


--
-- Name: oban_jobs_state_queue_priority_scheduled_at_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_queue_priority_scheduled_at_id_index ON public.oban_jobs USING btree (state, queue, priority, scheduled_at, id);


--
-- Name: one_autocreated_owner_per_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX one_autocreated_owner_per_user ON public.team_memberships USING btree (user_id) WHERE (((role)::text = 'owner'::text) AND (is_autocreated = true));


--
-- Name: plugins_api_tokens_site_id_token_hash_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plugins_api_tokens_site_id_token_hash_index ON public.plugins_api_tokens USING btree (site_id, token_hash);


--
-- Name: segments_owner_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX segments_owner_id_index ON public.segments USING btree (owner_id);


--
-- Name: segments_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX segments_site_id_index ON public.segments USING btree (site_id);


--
-- Name: sent_accept_traffic_until_notifications_user_id_sent_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sent_accept_traffic_until_notifications_user_id_sent_on_index ON public.sent_accept_traffic_until_notifications USING btree (user_id, sent_on);


--
-- Name: sent_renewal_notifications_user_id_timestamp_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sent_renewal_notifications_user_id_timestamp_index ON public.sent_renewal_notifications USING btree (user_id, "timestamp");


--
-- Name: setup_help_emails_site_id_timestamp_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX setup_help_emails_site_id_timestamp_index ON public.setup_help_emails USING btree (site_id, "timestamp");


--
-- Name: setup_success_emails_site_id_timestamp_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX setup_success_emails_site_id_timestamp_index ON public.setup_success_emails USING btree (site_id, "timestamp");


--
-- Name: shared_links_segment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX shared_links_segment_id_index ON public.shared_links USING btree (segment_id);


--
-- Name: shared_links_site_id_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX shared_links_site_id_name_index ON public.shared_links USING btree (site_id, name);


--
-- Name: shield_rules_country_site_id_country_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX shield_rules_country_site_id_country_code_index ON public.shield_rules_country USING btree (site_id, country_code);


--
-- Name: shield_rules_country_site_id_updated_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX shield_rules_country_site_id_updated_at_index ON public.shield_rules_country USING btree (site_id, updated_at);


--
-- Name: shield_rules_hostname_site_id_hostname_pattern_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX shield_rules_hostname_site_id_hostname_pattern_index ON public.shield_rules_hostname USING btree (site_id, hostname_pattern);


--
-- Name: shield_rules_ip_site_id_inet_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX shield_rules_ip_site_id_inet_index ON public.shield_rules_ip USING btree (site_id, inet);


--
-- Name: shield_rules_ip_site_id_updated_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX shield_rules_ip_site_id_updated_at_index ON public.shield_rules_ip USING btree (site_id, updated_at);


--
-- Name: shield_rules_page_site_id_page_path_pattern_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX shield_rules_page_site_id_page_path_pattern_index ON public.shield_rules_page USING btree (site_id, page_path_pattern);


--
-- Name: shield_rules_page_site_id_updated_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX shield_rules_page_site_id_updated_at_index ON public.shield_rules_page USING btree (site_id, updated_at);


--
-- Name: site_imports_imported_by_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_imports_imported_by_id_index ON public.site_imports USING btree (imported_by_id);


--
-- Name: site_imports_site_id_start_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_imports_site_id_start_date_index ON public.site_imports USING btree (site_id, start_date);


--
-- Name: site_memberships_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX site_memberships_site_id_index ON public.site_memberships USING btree (site_id) WHERE (role = 'owner'::public.site_membership_role);


--
-- Name: site_memberships_site_id_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX site_memberships_site_id_user_id_index ON public.site_memberships USING btree (site_id, user_id);


--
-- Name: site_user_preferences_user_id_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX site_user_preferences_user_id_site_id_index ON public.site_user_preferences USING btree (user_id, site_id);


--
-- Name: sites_domain_changed_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sites_domain_changed_at_index ON public.sites USING btree (domain_changed_at);


--
-- Name: sites_domain_changed_from_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sites_domain_changed_from_index ON public.sites USING btree (domain_changed_from);


--
-- Name: sites_domain_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sites_domain_index ON public.sites USING btree (domain);


--
-- Name: sites_team_id_consolidated_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sites_team_id_consolidated_id_index ON public.sites USING btree (team_id, consolidated, id);


--
-- Name: sites_team_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sites_team_id_index ON public.sites USING btree (team_id);


--
-- Name: sites_updated_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sites_updated_at_index ON public.sites USING btree (updated_at);


--
-- Name: spike_notifications_site_id_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX spike_notifications_site_id_type_index ON public.spike_notifications USING btree (site_id, type);


--
-- Name: subscriptions_paddle_subscription_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX subscriptions_paddle_subscription_id_index ON public.subscriptions USING btree (paddle_subscription_id);


--
-- Name: subscriptions_team_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscriptions_team_id_index ON public.subscriptions USING btree (team_id);


--
-- Name: team_invitations_email_role_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX team_invitations_email_role_index ON public.team_invitations USING btree (email, role);


--
-- Name: team_invitations_invitation_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX team_invitations_invitation_id_index ON public.team_invitations USING btree (invitation_id);


--
-- Name: team_invitations_inviter_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX team_invitations_inviter_id_index ON public.team_invitations USING btree (inviter_id);


--
-- Name: team_invitations_team_id_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX team_invitations_team_id_email_index ON public.team_invitations USING btree (team_id, email);


--
-- Name: team_invitations_team_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX team_invitations_team_id_index ON public.team_invitations USING btree (team_id);


--
-- Name: team_membership_user_preferences_team_membership_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX team_membership_user_preferences_team_membership_id_index ON public.team_membership_user_preferences USING btree (team_membership_id);


--
-- Name: team_memberships_team_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX team_memberships_team_id_index ON public.team_memberships USING btree (team_id);


--
-- Name: team_memberships_team_id_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX team_memberships_team_id_user_id_index ON public.team_memberships USING btree (team_id, user_id);


--
-- Name: team_memberships_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX team_memberships_user_id_index ON public.team_memberships USING btree (user_id);


--
-- Name: team_site_transfers_destination_team_id_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX team_site_transfers_destination_team_id_site_id_index ON public.team_site_transfers USING btree (destination_team_id, site_id);


--
-- Name: team_site_transfers_email_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX team_site_transfers_email_site_id_index ON public.team_site_transfers USING btree (email, site_id);


--
-- Name: team_site_transfers_transfer_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX team_site_transfers_transfer_id_index ON public.team_site_transfers USING btree (transfer_id);


--
-- Name: teams_identifier_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX teams_identifier_index ON public.teams USING btree (identifier);


--
-- Name: totp_recovery_codes_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX totp_recovery_codes_user_id_index ON public.totp_recovery_codes USING btree (user_id);


--
-- Name: tracker_script_configuration_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tracker_script_configuration_site_id_index ON public.tracker_script_configuration USING btree (site_id);


--
-- Name: tracker_script_configuration_updated_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tracker_script_configuration_updated_at_index ON public.tracker_script_configuration USING btree (updated_at);


--
-- Name: user_sessions_timeout_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_sessions_timeout_at_index ON public.user_sessions USING btree (timeout_at);


--
-- Name: user_sessions_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_sessions_token_index ON public.user_sessions USING btree (token);


--
-- Name: user_sessions_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_sessions_user_id_index ON public.user_sessions USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: weekly_reports_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX weekly_reports_site_id_index ON public.weekly_reports USING btree (site_id);


--
-- Name: sites check_domain_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_domain_trigger BEFORE INSERT OR UPDATE ON public.sites FOR EACH ROW EXECUTE FUNCTION public.check_domain();


--
-- Name: api_keys api_keys_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: api_keys api_keys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: check_stats_emails check_stats_emails_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_stats_emails
    ADD CONSTRAINT check_stats_emails_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: create_site_emails create_site_emails_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.create_site_emails
    ADD CONSTRAINT create_site_emails_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: email_activation_codes email_activation_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_activation_codes
    ADD CONSTRAINT email_activation_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: email_verification_codes email_verification_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verification_codes
    ADD CONSTRAINT email_verification_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: enterprise_plans enterprise_plans_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enterprise_plans
    ADD CONSTRAINT enterprise_plans_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: enterprise_plans enterprise_plans_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enterprise_plans
    ADD CONSTRAINT enterprise_plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: feedback_emails feedback_emails_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedback_emails
    ADD CONSTRAINT feedback_emails_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: funnel_steps funnel_steps_funnel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funnel_steps
    ADD CONSTRAINT funnel_steps_funnel_id_fkey FOREIGN KEY (funnel_id) REFERENCES public.funnels(id) ON DELETE CASCADE;


--
-- Name: funnel_steps funnel_steps_goal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funnel_steps
    ADD CONSTRAINT funnel_steps_goal_id_fkey FOREIGN KEY (goal_id) REFERENCES public.goals(id) ON DELETE CASCADE;


--
-- Name: funnels funnels_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funnels
    ADD CONSTRAINT funnels_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: goals goals_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: google_auth google_auth_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_auth
    ADD CONSTRAINT google_auth_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: google_auth google_auth_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_auth
    ADD CONSTRAINT google_auth_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: guest_invitations guest_invitations_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_invitations
    ADD CONSTRAINT guest_invitations_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: guest_invitations guest_invitations_team_invitation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_invitations
    ADD CONSTRAINT guest_invitations_team_invitation_id_fkey FOREIGN KEY (team_invitation_id) REFERENCES public.team_invitations(id) ON DELETE CASCADE;


--
-- Name: guest_memberships guest_memberships_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_memberships
    ADD CONSTRAINT guest_memberships_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: guest_memberships guest_memberships_team_membership_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_memberships
    ADD CONSTRAINT guest_memberships_team_membership_id_fkey FOREIGN KEY (team_membership_id) REFERENCES public.team_memberships(id) ON DELETE CASCADE;


--
-- Name: intro_emails intro_emails_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intro_emails
    ADD CONSTRAINT intro_emails_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: invitations invitations_inviter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_inviter_id_fkey FOREIGN KEY (inviter_id) REFERENCES public.users(id);


--
-- Name: invitations invitations_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: monthly_reports monthly_reports_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_reports
    ADD CONSTRAINT monthly_reports_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: plugins_api_tokens plugins_api_tokens_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugins_api_tokens
    ADD CONSTRAINT plugins_api_tokens_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: segments segments_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.segments
    ADD CONSTRAINT segments_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: segments segments_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.segments
    ADD CONSTRAINT segments_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: sent_accept_traffic_until_notifications sent_accept_traffic_until_notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_accept_traffic_until_notifications
    ADD CONSTRAINT sent_accept_traffic_until_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sent_monthly_reports sent_monthly_reports_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_monthly_reports
    ADD CONSTRAINT sent_monthly_reports_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: sent_renewal_notifications sent_renewal_notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_renewal_notifications
    ADD CONSTRAINT sent_renewal_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sent_weekly_reports sent_weekly_reports_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sent_weekly_reports
    ADD CONSTRAINT sent_weekly_reports_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: setup_help_emails setup_help_emails_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.setup_help_emails
    ADD CONSTRAINT setup_help_emails_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: setup_success_emails setup_success_emails_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.setup_success_emails
    ADD CONSTRAINT setup_success_emails_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: shared_links shared_links_segment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_links
    ADD CONSTRAINT shared_links_segment_id_fkey FOREIGN KEY (segment_id) REFERENCES public.segments(id) ON DELETE CASCADE;


--
-- Name: shared_links shared_links_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_links
    ADD CONSTRAINT shared_links_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: shield_rules_country shield_rules_country_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shield_rules_country
    ADD CONSTRAINT shield_rules_country_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: shield_rules_hostname shield_rules_hostname_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shield_rules_hostname
    ADD CONSTRAINT shield_rules_hostname_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: shield_rules_ip shield_rules_ip_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shield_rules_ip
    ADD CONSTRAINT shield_rules_ip_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: shield_rules_page shield_rules_page_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shield_rules_page
    ADD CONSTRAINT shield_rules_page_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: site_imports site_imports_imported_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_imports
    ADD CONSTRAINT site_imports_imported_by_id_fkey FOREIGN KEY (imported_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: site_imports site_imports_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_imports
    ADD CONSTRAINT site_imports_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: site_memberships site_memberships_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_memberships
    ADD CONSTRAINT site_memberships_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: site_memberships site_memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_memberships
    ADD CONSTRAINT site_memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: site_user_preferences site_user_preferences_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_user_preferences
    ADD CONSTRAINT site_user_preferences_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: site_user_preferences site_user_preferences_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_user_preferences
    ADD CONSTRAINT site_user_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sites sites_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: spike_notifications spike_notifications_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spike_notifications
    ADD CONSTRAINT spike_notifications_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: team_invitations team_invitations_inviter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_inviter_id_fkey FOREIGN KEY (inviter_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: team_invitations team_invitations_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: team_membership_user_preferences team_membership_user_preferences_team_membership_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_membership_user_preferences
    ADD CONSTRAINT team_membership_user_preferences_team_membership_id_fkey FOREIGN KEY (team_membership_id) REFERENCES public.team_memberships(id) ON DELETE CASCADE;


--
-- Name: team_memberships team_memberships_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_memberships
    ADD CONSTRAINT team_memberships_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: team_memberships team_memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_memberships
    ADD CONSTRAINT team_memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: team_site_transfers team_site_transfers_destination_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_site_transfers
    ADD CONSTRAINT team_site_transfers_destination_team_id_fkey FOREIGN KEY (destination_team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: team_site_transfers team_site_transfers_initiator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_site_transfers
    ADD CONSTRAINT team_site_transfers_initiator_id_fkey FOREIGN KEY (initiator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: team_site_transfers team_site_transfers_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_site_transfers
    ADD CONSTRAINT team_site_transfers_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: totp_recovery_codes totp_recovery_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.totp_recovery_codes
    ADD CONSTRAINT totp_recovery_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tracker_script_configuration tracker_script_configuration_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracker_script_configuration
    ADD CONSTRAINT tracker_script_configuration_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: weekly_reports weekly_reports_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weekly_reports
    ADD CONSTRAINT weekly_reports_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


