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
-- Name: api_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_tokens (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    token_salt character varying(255) NOT NULL,
    token_hash character varying(255) NOT NULL,
    token_last_eight character varying(8) NOT NULL,
    permissions json NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created timestamp without time zone NOT NULL,
    owner_id bigint NOT NULL
);


--
-- Name: api_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_tokens_id_seq OWNED BY public.api_tokens.id;


--
-- Name: buckets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buckets (
    id bigint NOT NULL,
    title text NOT NULL,
    project_view_id bigint NOT NULL,
    "limit" bigint DEFAULT 0,
    "position" double precision,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    created_by_id bigint NOT NULL
);


--
-- Name: buckets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.buckets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: buckets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.buckets_id_seq OWNED BY public.buckets.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    entity_id bigint NOT NULL,
    user_id bigint NOT NULL,
    kind integer NOT NULL
);


--
-- Name: files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.files (
    id bigint NOT NULL,
    name text NOT NULL,
    mime text,
    size bigint NOT NULL,
    created timestamp without time zone,
    created_by_id bigint NOT NULL
);


--
-- Name: files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.files_id_seq OWNED BY public.files.id;


--
-- Name: label_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.label_tasks (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    label_id bigint NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: label_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.label_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: label_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.label_tasks_id_seq OWNED BY public.label_tasks.id;


--
-- Name: labels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.labels (
    id bigint NOT NULL,
    title character varying(250) NOT NULL,
    description text,
    hex_color character varying(6),
    created_by_id bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: labels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: labels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.labels_id_seq OWNED BY public.labels.id;


--
-- Name: license_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.license_status (
    id bigint NOT NULL,
    instance_id character varying(36) NOT NULL,
    response text NOT NULL,
    validated_at timestamp without time zone,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: license_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.license_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.license_status_id_seq OWNED BY public.license_status.id;


--
-- Name: link_shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.link_shares (
    id bigint NOT NULL,
    hash character varying(40) NOT NULL,
    name text,
    project_id bigint NOT NULL,
    permission bigint DEFAULT 0 NOT NULL,
    sharing_type bigint DEFAULT 0 NOT NULL,
    password text,
    shared_by_id bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: link_shares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.link_shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.link_shares_id_seq OWNED BY public.link_shares.id;


--
-- Name: migration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migration (
    id character varying(255),
    description character varying(255)
);


--
-- Name: migration_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migration_status (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    migrator_name character varying(255),
    started_at timestamp without time zone NOT NULL,
    finished_at timestamp without time zone
);


--
-- Name: migration_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migration_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migration_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migration_status_id_seq OWNED BY public.migration_status.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    notifiable_id bigint NOT NULL,
    notification json NOT NULL,
    name character varying(250) NOT NULL,
    subject_id bigint,
    project_id bigint DEFAULT 0 NOT NULL,
    read_at timestamp without time zone,
    created timestamp without time zone NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: oauth_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_codes (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    code character varying(128) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    client_id character varying(255) NOT NULL,
    redirect_uri text NOT NULL,
    code_challenge character varying(128) NOT NULL,
    code_challenge_method character varying(10) NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: oauth_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_codes_id_seq OWNED BY public.oauth_codes.id;


--
-- Name: project_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_views (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    project_id bigint NOT NULL,
    view_kind integer NOT NULL,
    filter json,
    "position" double precision,
    bucket_configuration_mode integer DEFAULT 0,
    bucket_configuration json,
    default_bucket_id bigint,
    done_bucket_id bigint,
    updated timestamp without time zone NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: project_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_views_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_views_id_seq OWNED BY public.project_views.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id bigint NOT NULL,
    title character varying(250) NOT NULL,
    description text,
    identifier character varying(10),
    hex_color character varying(6),
    owner_id bigint NOT NULL,
    parent_project_id bigint,
    is_archived boolean DEFAULT false NOT NULL,
    background_file_id bigint,
    background_blur_hash character varying(50),
    "position" double precision,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reactions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    entity_kind bigint NOT NULL,
    value character varying(20) NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: reactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reactions_id_seq OWNED BY public.reactions.id;


--
-- Name: saved_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saved_filters (
    id bigint NOT NULL,
    filters json NOT NULL,
    title character varying(250) NOT NULL,
    description text,
    owner_id bigint NOT NULL,
    is_favorite boolean DEFAULT false,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: saved_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.saved_filters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saved_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.saved_filters_id_seq OWNED BY public.saved_filters.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id character varying(36) NOT NULL,
    user_id bigint NOT NULL,
    token_hash character varying(64) NOT NULL,
    device_info text,
    ip_address character varying(100),
    is_long_session boolean DEFAULT false NOT NULL,
    oidcid_token text,
    oidc_provider_key character varying(250),
    last_active timestamp without time zone NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id bigint NOT NULL,
    entity_type integer NOT NULL,
    entity_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created timestamp without time zone NOT NULL
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
-- Name: task_assignees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_assignees (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: task_assignees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_assignees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_assignees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_assignees_id_seq OWNED BY public.task_assignees.id;


--
-- Name: task_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_attachments (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    file_id bigint NOT NULL,
    created_by_id bigint NOT NULL,
    created timestamp without time zone
);


--
-- Name: task_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_attachments_id_seq OWNED BY public.task_attachments.id;


--
-- Name: task_buckets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_buckets (
    bucket_id bigint NOT NULL,
    task_id bigint NOT NULL,
    project_view_id bigint NOT NULL
);


--
-- Name: task_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_comments (
    id bigint NOT NULL,
    comment text NOT NULL,
    author_id bigint NOT NULL,
    task_id bigint NOT NULL,
    created timestamp without time zone,
    updated timestamp without time zone
);


--
-- Name: task_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_comments_id_seq OWNED BY public.task_comments.id;


--
-- Name: task_positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_positions (
    task_id bigint NOT NULL,
    project_view_id bigint NOT NULL,
    "position" double precision NOT NULL
);


--
-- Name: task_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_relations (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    other_task_id bigint NOT NULL,
    relation_kind character varying(50) NOT NULL,
    created_by_id bigint NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: task_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_relations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_relations_id_seq OWNED BY public.task_relations.id;


--
-- Name: task_reminders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_reminders (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    reminder timestamp without time zone NOT NULL,
    created timestamp without time zone NOT NULL,
    relative_period bigint,
    relative_to character varying(50)
);


--
-- Name: task_reminders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_reminders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_reminders_id_seq OWNED BY public.task_reminders.id;


--
-- Name: task_unread_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_unread_statuses (
    task_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks (
    id bigint NOT NULL,
    title text NOT NULL,
    description text,
    done boolean,
    done_at timestamp without time zone,
    due_date timestamp without time zone,
    project_id bigint NOT NULL,
    repeat_after bigint,
    repeat_mode integer DEFAULT 0 NOT NULL,
    priority bigint,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    hex_color character varying(6),
    percent_done double precision,
    index bigint DEFAULT 0 NOT NULL,
    uid character varying(250),
    cover_image_attachment_id bigint DEFAULT 0,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    created_by_id bigint NOT NULL
);


--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- Name: team_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_members (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    user_id bigint NOT NULL,
    admin boolean,
    created timestamp without time zone NOT NULL
);


--
-- Name: team_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_members_id_seq OWNED BY public.team_members.id;


--
-- Name: team_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_projects (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    project_id bigint NOT NULL,
    permission bigint DEFAULT 0 NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: team_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_projects_id_seq OWNED BY public.team_projects.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id bigint NOT NULL,
    name character varying(250) NOT NULL,
    description text,
    created_by_id bigint NOT NULL,
    external_id character varying(250),
    issuer text,
    created timestamp without time zone,
    updated timestamp without time zone,
    is_public boolean DEFAULT false NOT NULL
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
-- Name: time_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.time_entries (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    task_id bigint,
    project_id bigint,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    comment text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: time_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.time_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: time_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.time_entries_id_seq OWNED BY public.time_entries.id;


--
-- Name: totp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.totp (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    secret text NOT NULL,
    enabled boolean,
    url text
);


--
-- Name: totp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.totp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: totp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.totp_id_seq OWNED BY public.totp.id;


--
-- Name: unsplash_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unsplash_photos (
    id bigint NOT NULL,
    file_id bigint NOT NULL,
    unsplash_id character varying(50),
    author text,
    author_name text
);


--
-- Name: unsplash_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.unsplash_photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unsplash_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.unsplash_photos_id_seq OWNED BY public.unsplash_photos.id;


--
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token character varying(450) NOT NULL,
    kind integer NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: user_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_tokens_id_seq OWNED BY public.user_tokens.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name text,
    username character varying(250) NOT NULL,
    password character varying(250),
    email character varying(250),
    status integer DEFAULT 0,
    is_admin boolean DEFAULT false NOT NULL,
    avatar_provider character varying(255),
    avatar_file_id bigint,
    issuer text,
    subject text,
    email_reminders_enabled boolean DEFAULT true,
    discoverable_by_name boolean DEFAULT false,
    discoverable_by_email boolean DEFAULT false,
    overdue_tasks_reminders_enabled boolean DEFAULT true,
    overdue_tasks_reminders_time character varying(5) DEFAULT '09:00'::character varying NOT NULL,
    default_project_id bigint,
    bot_owner_id bigint,
    week_start integer,
    language character varying(50),
    timezone character varying(255),
    deletion_scheduled_at timestamp without time zone,
    deletion_last_reminder_sent timestamp without time zone,
    frontend_settings json,
    extra_settings_links json,
    export_file_id bigint,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
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
-- Name: users_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_projects (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    project_id bigint NOT NULL,
    permission bigint DEFAULT 0 NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: users_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_projects_id_seq OWNED BY public.users_projects.id;


--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks (
    id bigint NOT NULL,
    target_url character varying(255) NOT NULL,
    events json NOT NULL,
    project_id bigint,
    user_id bigint,
    secret character varying(255),
    basic_auth_user character varying(255),
    basic_auth_password character varying(255),
    created_by_id bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhooks_id_seq
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
-- Name: api_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_tokens ALTER COLUMN id SET DEFAULT nextval('public.api_tokens_id_seq'::regclass);


--
-- Name: buckets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buckets ALTER COLUMN id SET DEFAULT nextval('public.buckets_id_seq'::regclass);


--
-- Name: files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.files ALTER COLUMN id SET DEFAULT nextval('public.files_id_seq'::regclass);


--
-- Name: label_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.label_tasks ALTER COLUMN id SET DEFAULT nextval('public.label_tasks_id_seq'::regclass);


--
-- Name: labels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels ALTER COLUMN id SET DEFAULT nextval('public.labels_id_seq'::regclass);


--
-- Name: license_status id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.license_status ALTER COLUMN id SET DEFAULT nextval('public.license_status_id_seq'::regclass);


--
-- Name: link_shares id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_shares ALTER COLUMN id SET DEFAULT nextval('public.link_shares_id_seq'::regclass);


--
-- Name: migration_status id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migration_status ALTER COLUMN id SET DEFAULT nextval('public.migration_status_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: oauth_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_codes ALTER COLUMN id SET DEFAULT nextval('public.oauth_codes_id_seq'::regclass);


--
-- Name: project_views id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_views ALTER COLUMN id SET DEFAULT nextval('public.project_views_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: reactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions ALTER COLUMN id SET DEFAULT nextval('public.reactions_id_seq'::regclass);


--
-- Name: saved_filters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_filters ALTER COLUMN id SET DEFAULT nextval('public.saved_filters_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: task_assignees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_assignees ALTER COLUMN id SET DEFAULT nextval('public.task_assignees_id_seq'::regclass);


--
-- Name: task_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_attachments ALTER COLUMN id SET DEFAULT nextval('public.task_attachments_id_seq'::regclass);


--
-- Name: task_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_comments ALTER COLUMN id SET DEFAULT nextval('public.task_comments_id_seq'::regclass);


--
-- Name: task_relations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_relations ALTER COLUMN id SET DEFAULT nextval('public.task_relations_id_seq'::regclass);


--
-- Name: task_reminders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_reminders ALTER COLUMN id SET DEFAULT nextval('public.task_reminders_id_seq'::regclass);


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- Name: team_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members ALTER COLUMN id SET DEFAULT nextval('public.team_members_id_seq'::regclass);


--
-- Name: team_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_projects ALTER COLUMN id SET DEFAULT nextval('public.team_projects_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: time_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entries ALTER COLUMN id SET DEFAULT nextval('public.time_entries_id_seq'::regclass);


--
-- Name: totp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.totp ALTER COLUMN id SET DEFAULT nextval('public.totp_id_seq'::regclass);


--
-- Name: unsplash_photos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unsplash_photos ALTER COLUMN id SET DEFAULT nextval('public.unsplash_photos_id_seq'::regclass);


--
-- Name: user_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tokens ALTER COLUMN id SET DEFAULT nextval('public.user_tokens_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_projects ALTER COLUMN id SET DEFAULT nextval('public.users_projects_id_seq'::regclass);


--
-- Name: webhooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks ALTER COLUMN id SET DEFAULT nextval('public.webhooks_id_seq'::regclass);


--
-- Name: api_tokens api_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_tokens
    ADD CONSTRAINT api_tokens_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (entity_id, user_id, kind);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: label_tasks label_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.label_tasks
    ADD CONSTRAINT label_tasks_pkey PRIMARY KEY (id);


--
-- Name: labels labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);


--
-- Name: license_status license_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.license_status
    ADD CONSTRAINT license_status_pkey PRIMARY KEY (id);


--
-- Name: link_shares link_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_shares
    ADD CONSTRAINT link_shares_pkey PRIMARY KEY (id);


--
-- Name: migration_status migration_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migration_status
    ADD CONSTRAINT migration_status_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_codes oauth_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_codes
    ADD CONSTRAINT oauth_codes_pkey PRIMARY KEY (id);


--
-- Name: project_views project_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_views
    ADD CONSTRAINT project_views_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: reactions reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_pkey PRIMARY KEY (id);


--
-- Name: saved_filters saved_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_filters
    ADD CONSTRAINT saved_filters_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: task_assignees task_assignees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_assignees
    ADD CONSTRAINT task_assignees_pkey PRIMARY KEY (id);


--
-- Name: task_attachments task_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_attachments
    ADD CONSTRAINT task_attachments_pkey PRIMARY KEY (id);


--
-- Name: task_comments task_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_comments
    ADD CONSTRAINT task_comments_pkey PRIMARY KEY (id);


--
-- Name: task_relations task_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_relations
    ADD CONSTRAINT task_relations_pkey PRIMARY KEY (id);


--
-- Name: task_reminders task_reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_reminders
    ADD CONSTRAINT task_reminders_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: team_members team_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_pkey PRIMARY KEY (id);


--
-- Name: team_projects team_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_projects
    ADD CONSTRAINT team_projects_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: time_entries time_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entries
    ADD CONSTRAINT time_entries_pkey PRIMARY KEY (id);


--
-- Name: totp totp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.totp
    ADD CONSTRAINT totp_pkey PRIMARY KEY (id);


--
-- Name: unsplash_photos unsplash_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unsplash_photos
    ADD CONSTRAINT unsplash_photos_pkey PRIMARY KEY (id);


--
-- Name: user_tokens user_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_projects users_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_projects
    ADD CONSTRAINT users_projects_pkey PRIMARY KEY (id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);


--
-- Name: IDX_api_tokens_token_last_eight; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_api_tokens_token_last_eight" ON public.api_tokens USING btree (token_last_eight);


--
-- Name: IDX_label_tasks_label_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_label_tasks_label_id" ON public.label_tasks USING btree (label_id);


--
-- Name: IDX_label_tasks_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_label_tasks_task_id" ON public.label_tasks USING btree (task_id);


--
-- Name: IDX_link_shares_permission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_link_shares_permission" ON public.link_shares USING btree (permission);


--
-- Name: IDX_link_shares_shared_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_link_shares_shared_by_id" ON public.link_shares USING btree (shared_by_id);


--
-- Name: IDX_link_shares_sharing_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_link_shares_sharing_type" ON public.link_shares USING btree (sharing_type);


--
-- Name: IDX_notifications_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_notifications_name" ON public.notifications USING btree (name);


--
-- Name: IDX_notifications_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_notifications_project_id" ON public.notifications USING btree (project_id);


--
-- Name: IDX_project_views_default_bucket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_project_views_default_bucket_id" ON public.project_views USING btree (default_bucket_id);


--
-- Name: IDX_project_views_done_bucket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_project_views_done_bucket_id" ON public.project_views USING btree (done_bucket_id);


--
-- Name: IDX_project_views_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_project_views_project_id" ON public.project_views USING btree (project_id);


--
-- Name: IDX_projects_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_projects_owner_id" ON public.projects USING btree (owner_id);


--
-- Name: IDX_projects_parent_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_projects_parent_project_id" ON public.projects USING btree (parent_project_id);


--
-- Name: IDX_reactions_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reactions_entity_id" ON public.reactions USING btree (entity_id);


--
-- Name: IDX_reactions_entity_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reactions_entity_kind" ON public.reactions USING btree (entity_kind);


--
-- Name: IDX_reactions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reactions_user_id" ON public.reactions USING btree (user_id);


--
-- Name: IDX_reactions_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reactions_value" ON public.reactions USING btree (value);


--
-- Name: IDX_saved_filters_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_saved_filters_owner_id" ON public.saved_filters USING btree (owner_id);


--
-- Name: IDX_sessions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_sessions_user_id" ON public.sessions USING btree (user_id);


--
-- Name: IDX_subscriptions_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_subscriptions_entity_id" ON public.subscriptions USING btree (entity_id);


--
-- Name: IDX_subscriptions_entity_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_subscriptions_entity_type" ON public.subscriptions USING btree (entity_type);


--
-- Name: IDX_subscriptions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_subscriptions_user_id" ON public.subscriptions USING btree (user_id);


--
-- Name: IDX_task_assignees_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_task_assignees_task_id" ON public.task_assignees USING btree (task_id);


--
-- Name: IDX_task_assignees_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_task_assignees_user_id" ON public.task_assignees USING btree (user_id);


--
-- Name: IDX_task_buckets_bucket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_task_buckets_bucket_id" ON public.task_buckets USING btree (bucket_id);


--
-- Name: IDX_task_buckets_project_view_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_task_buckets_project_view_id" ON public.task_buckets USING btree (project_view_id);


--
-- Name: IDX_task_buckets_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_task_buckets_task_id" ON public.task_buckets USING btree (task_id);


--
-- Name: IDX_task_comments_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_task_comments_task_id" ON public.task_comments USING btree (task_id);


--
-- Name: IDX_task_positions_project_view_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_task_positions_project_view_id" ON public.task_positions USING btree (project_view_id);


--
-- Name: IDX_task_positions_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_task_positions_task_id" ON public.task_positions USING btree (task_id);


--
-- Name: IDX_task_positions_view_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_task_positions_view_position" ON public.task_positions USING btree (project_view_id, "position");


--
-- Name: IDX_task_reminders_reminder; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_task_reminders_reminder" ON public.task_reminders USING btree (reminder);


--
-- Name: IDX_task_reminders_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_task_reminders_task_id" ON public.task_reminders USING btree (task_id);


--
-- Name: IDX_tasks_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tasks_deleted_at" ON public.tasks USING btree (deleted_at);


--
-- Name: IDX_tasks_done; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tasks_done" ON public.tasks USING btree (done);


--
-- Name: IDX_tasks_done_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tasks_done_at" ON public.tasks USING btree (done_at);


--
-- Name: IDX_tasks_due_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tasks_due_date" ON public.tasks USING btree (due_date);


--
-- Name: IDX_tasks_end_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tasks_end_date" ON public.tasks USING btree (end_date);


--
-- Name: IDX_tasks_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tasks_project_id" ON public.tasks USING btree (project_id);


--
-- Name: IDX_tasks_repeat_after; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tasks_repeat_after" ON public.tasks USING btree (repeat_after);


--
-- Name: IDX_tasks_start_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tasks_start_date" ON public.tasks USING btree (start_date);


--
-- Name: IDX_team_members_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_team_members_team_id" ON public.team_members USING btree (team_id);


--
-- Name: IDX_team_members_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_team_members_user_id" ON public.team_members USING btree (user_id);


--
-- Name: IDX_team_projects_permission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_team_projects_permission" ON public.team_projects USING btree (permission);


--
-- Name: IDX_team_projects_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_team_projects_project_id" ON public.team_projects USING btree (project_id);


--
-- Name: IDX_team_projects_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_team_projects_team_id" ON public.team_projects USING btree (team_id);


--
-- Name: IDX_teams_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_teams_created_by_id" ON public.teams USING btree (created_by_id);


--
-- Name: IDX_time_entries_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_time_entries_project_id" ON public.time_entries USING btree (project_id);


--
-- Name: IDX_time_entries_start_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_time_entries_start_time" ON public.time_entries USING btree (start_time);


--
-- Name: IDX_time_entries_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_time_entries_task_id" ON public.time_entries USING btree (task_id);


--
-- Name: IDX_time_entries_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_time_entries_user_id" ON public.time_entries USING btree (user_id);


--
-- Name: IDX_user_tokens_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_tokens_token" ON public.user_tokens USING btree (token);


--
-- Name: IDX_users_bot_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_users_bot_owner_id" ON public.users USING btree (bot_owner_id);


--
-- Name: IDX_users_default_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_users_default_project_id" ON public.users USING btree (default_project_id);


--
-- Name: IDX_users_discoverable_by_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_users_discoverable_by_email" ON public.users USING btree (discoverable_by_email);


--
-- Name: IDX_users_discoverable_by_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_users_discoverable_by_name" ON public.users USING btree (discoverable_by_name);


--
-- Name: IDX_users_overdue_tasks_reminders_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_users_overdue_tasks_reminders_enabled" ON public.users USING btree (overdue_tasks_reminders_enabled);


--
-- Name: IDX_users_projects_permission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_users_projects_permission" ON public.users_projects USING btree (permission);


--
-- Name: IDX_users_projects_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_users_projects_project_id" ON public.users_projects USING btree (project_id);


--
-- Name: IDX_users_projects_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_users_projects_user_id" ON public.users_projects USING btree (user_id);


--
-- Name: IDX_webhooks_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_webhooks_project_id" ON public.webhooks USING btree (project_id);


--
-- Name: IDX_webhooks_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_webhooks_user_id" ON public.webhooks USING btree (user_id);


--
-- Name: UQE_api_tokens_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_api_tokens_id" ON public.api_tokens USING btree (id);


--
-- Name: UQE_api_tokens_token_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_api_tokens_token_hash" ON public.api_tokens USING btree (token_hash);


--
-- Name: UQE_buckets_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_buckets_id" ON public.buckets USING btree (id);


--
-- Name: UQE_files_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_files_id" ON public.files USING btree (id);


--
-- Name: UQE_label_tasks_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_label_tasks_id" ON public.label_tasks USING btree (id);


--
-- Name: UQE_labels_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_labels_id" ON public.labels USING btree (id);


--
-- Name: UQE_license_status_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_license_status_id" ON public.license_status USING btree (id);


--
-- Name: UQE_link_shares_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_link_shares_hash" ON public.link_shares USING btree (hash);


--
-- Name: UQE_link_shares_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_link_shares_id" ON public.link_shares USING btree (id);


--
-- Name: UQE_migration_status_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_migration_status_id" ON public.migration_status USING btree (id);


--
-- Name: UQE_notifications_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_notifications_id" ON public.notifications USING btree (id);


--
-- Name: UQE_oauth_codes_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_oauth_codes_code" ON public.oauth_codes USING btree (code);


--
-- Name: UQE_oauth_codes_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_oauth_codes_id" ON public.oauth_codes USING btree (id);


--
-- Name: UQE_project_views_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_project_views_id" ON public.project_views USING btree (id);


--
-- Name: UQE_projects_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_projects_id" ON public.projects USING btree (id);


--
-- Name: UQE_reactions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_reactions_id" ON public.reactions USING btree (id);


--
-- Name: UQE_saved_filters_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_saved_filters_id" ON public.saved_filters USING btree (id);


--
-- Name: UQE_sessions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_sessions_id" ON public.sessions USING btree (id);


--
-- Name: UQE_sessions_token_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_sessions_token_hash" ON public.sessions USING btree (token_hash);


--
-- Name: UQE_subscriptions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_subscriptions_id" ON public.subscriptions USING btree (id);


--
-- Name: UQE_task_assignees_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_task_assignees_id" ON public.task_assignees USING btree (id);


--
-- Name: UQE_task_attachments_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_task_attachments_id" ON public.task_attachments USING btree (id);


--
-- Name: UQE_task_buckets_task_view; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_task_buckets_task_view" ON public.task_buckets USING btree (task_id, project_view_id);


--
-- Name: UQE_task_comments_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_task_comments_id" ON public.task_comments USING btree (id);


--
-- Name: UQE_task_positions_task_view; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_task_positions_task_view" ON public.task_positions USING btree (task_id, project_view_id);


--
-- Name: UQE_task_relations_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_task_relations_id" ON public.task_relations USING btree (id);


--
-- Name: UQE_task_reminders_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_task_reminders_id" ON public.task_reminders USING btree (id);


--
-- Name: UQE_task_unread_statuses_task_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_task_unread_statuses_task_user" ON public.task_unread_statuses USING btree (task_id, user_id);


--
-- Name: UQE_tasks_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_tasks_id" ON public.tasks USING btree (id);


--
-- Name: UQE_tasks_tasks_project_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_tasks_tasks_project_index" ON public.tasks USING btree (project_id, index);


--
-- Name: UQE_team_members_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_team_members_id" ON public.team_members USING btree (id);


--
-- Name: UQE_team_projects_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_team_projects_id" ON public.team_projects USING btree (id);


--
-- Name: UQE_teams_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_teams_id" ON public.teams USING btree (id);


--
-- Name: UQE_time_entries_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_time_entries_id" ON public.time_entries USING btree (id);


--
-- Name: UQE_totp_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_totp_id" ON public.totp USING btree (id);


--
-- Name: UQE_unsplash_photos_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_unsplash_photos_id" ON public.unsplash_photos USING btree (id);


--
-- Name: UQE_user_tokens_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_user_tokens_id" ON public.user_tokens USING btree (id);


--
-- Name: UQE_users_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_users_id" ON public.users USING btree (id);


--
-- Name: UQE_users_projects_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_users_projects_id" ON public.users_projects USING btree (id);


--
-- Name: UQE_users_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_users_username" ON public.users USING btree (username);


--
-- Name: UQE_webhooks_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_webhooks_id" ON public.webhooks USING btree (id);


--
-- PostgreSQL database dump complete
--


