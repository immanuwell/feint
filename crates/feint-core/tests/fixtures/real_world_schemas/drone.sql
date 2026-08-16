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
-- Name: builds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builds (
    build_id integer NOT NULL,
    build_repo_id integer,
    build_config_id integer,
    build_trigger character varying(250),
    build_number integer,
    build_parent integer,
    build_status character varying(50),
    build_error character varying(500),
    build_event character varying(50),
    build_action character varying(50),
    build_link character varying(2000),
    build_timestamp integer,
    build_title character varying(2000),
    build_message character varying(2000),
    build_before character varying(50),
    build_after character varying(50),
    build_ref character varying(500),
    build_source_repo character varying(250),
    build_source character varying(500),
    build_target character varying(500),
    build_author character varying(500),
    build_author_name character varying(500),
    build_author_email character varying(500),
    build_author_avatar character varying(2000),
    build_sender character varying(500),
    build_deploy character varying(500),
    build_params character varying(4000),
    build_started integer,
    build_finished integer,
    build_created integer,
    build_updated integer,
    build_version integer,
    build_debug boolean DEFAULT false NOT NULL,
    build_cron character varying(50) DEFAULT ''::character varying NOT NULL,
    build_deploy_id bigint DEFAULT 0 NOT NULL
);


--
-- Name: builds_build_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.builds_build_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: builds_build_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.builds_build_id_seq OWNED BY public.builds.build_id;


--
-- Name: cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cards (
    card_id integer NOT NULL,
    card_data bytea
);


--
-- Name: cards_card_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cards_card_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cards_card_id_seq OWNED BY public.cards.card_id;


--
-- Name: cron; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cron (
    cron_id integer NOT NULL,
    cron_repo_id integer,
    cron_name character varying(50),
    cron_expr character varying(50),
    cron_next integer,
    cron_prev integer,
    cron_event character varying(50),
    cron_branch character varying(250),
    cron_target character varying(250),
    cron_disabled boolean,
    cron_created integer,
    cron_updated integer,
    cron_version integer
);


--
-- Name: cron_cron_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cron_cron_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cron_cron_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cron_cron_id_seq OWNED BY public.cron.cron_id;


--
-- Name: latest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.latest (
    latest_repo_id integer NOT NULL,
    latest_build_id integer,
    latest_type character varying(50) NOT NULL,
    latest_name character varying(500) NOT NULL,
    latest_created integer,
    latest_updated integer,
    latest_deleted integer
);


--
-- Name: logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logs (
    log_id integer NOT NULL,
    log_data bytea
);


--
-- Name: logs_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.logs_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logs_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.logs_log_id_seq OWNED BY public.logs.log_id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    name character varying(255)
);


--
-- Name: nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nodes (
    node_id integer NOT NULL,
    node_uid character varying(500),
    node_provider character varying(50),
    node_state character varying(50),
    node_name character varying(50),
    node_image character varying(500),
    node_region character varying(100),
    node_size character varying(100),
    node_os character varying(50),
    node_arch character varying(50),
    node_kernel character varying(50),
    node_variant character varying(50),
    node_address character varying(500),
    node_capacity integer,
    node_filter character varying(2000),
    node_labels character varying(2000),
    node_error character varying(2000),
    node_ca_key bytea,
    node_ca_cert bytea,
    node_tls_key bytea,
    node_tls_cert bytea,
    node_tls_name character varying(500),
    node_paused boolean,
    node_protected boolean,
    node_created integer,
    node_updated integer,
    node_pulled integer
);


--
-- Name: nodes_node_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nodes_node_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nodes_node_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nodes_node_id_seq OWNED BY public.nodes.node_id;


--
-- Name: orgsecrets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orgsecrets (
    secret_id integer NOT NULL,
    secret_namespace character varying(50),
    secret_name character varying(200),
    secret_type character varying(50),
    secret_data bytea,
    secret_pull_request boolean,
    secret_pull_request_push boolean
);


--
-- Name: orgsecrets_secret_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orgsecrets_secret_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orgsecrets_secret_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orgsecrets_secret_id_seq OWNED BY public.orgsecrets.secret_id;


--
-- Name: perms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.perms (
    perm_user_id integer NOT NULL,
    perm_repo_uid character varying(250) NOT NULL,
    perm_read boolean,
    perm_write boolean,
    perm_admin boolean,
    perm_synced integer,
    perm_created integer,
    perm_updated integer
);


--
-- Name: repos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repos (
    repo_id integer NOT NULL,
    repo_uid character varying(250),
    repo_user_id integer,
    repo_namespace character varying(250),
    repo_name character varying(250),
    repo_slug character varying(250),
    repo_scm character varying(50),
    repo_clone_url character varying(2000),
    repo_ssh_url character varying(2000),
    repo_html_url character varying(2000),
    repo_active boolean,
    repo_private boolean,
    repo_visibility character varying(50),
    repo_branch character varying(250),
    repo_counter integer,
    repo_config character varying(500),
    repo_timeout integer,
    repo_trusted boolean,
    repo_protected boolean,
    repo_synced integer,
    repo_created integer,
    repo_updated integer,
    repo_version integer,
    repo_signer character varying(50),
    repo_secret character varying(50),
    repo_no_forks boolean DEFAULT false NOT NULL,
    repo_no_pulls boolean DEFAULT false NOT NULL,
    repo_cancel_pulls boolean DEFAULT false NOT NULL,
    repo_cancel_push boolean DEFAULT false NOT NULL,
    repo_throttle integer DEFAULT 0 NOT NULL,
    repo_cancel_running boolean DEFAULT false NOT NULL
);


--
-- Name: repos_repo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repos_repo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repos_repo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repos_repo_id_seq OWNED BY public.repos.repo_id;


--
-- Name: secrets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secrets (
    secret_id integer NOT NULL,
    secret_repo_id integer,
    secret_name character varying(500),
    secret_data bytea,
    secret_pull_request boolean,
    secret_pull_request_push boolean
);


--
-- Name: secrets_secret_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.secrets_secret_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: secrets_secret_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.secrets_secret_id_seq OWNED BY public.secrets.secret_id;


--
-- Name: stages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stages (
    stage_id integer NOT NULL,
    stage_repo_id integer,
    stage_build_id integer,
    stage_number integer,
    stage_name character varying(100),
    stage_kind character varying(50),
    stage_type character varying(50),
    stage_status character varying(50),
    stage_error character varying(500),
    stage_errignore boolean,
    stage_exit_code integer,
    stage_limit integer,
    stage_os character varying(50),
    stage_arch character varying(50),
    stage_variant character varying(10),
    stage_kernel character varying(50),
    stage_machine character varying(500),
    stage_started integer,
    stage_stopped integer,
    stage_created integer,
    stage_updated integer,
    stage_version integer,
    stage_on_success boolean,
    stage_on_failure boolean,
    stage_depends_on text,
    stage_labels text,
    stage_limit_repo integer DEFAULT 0 NOT NULL
);


--
-- Name: stages_stage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stages_stage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stages_stage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stages_stage_id_seq OWNED BY public.stages.stage_id;


--
-- Name: steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.steps (
    step_id integer NOT NULL,
    step_stage_id integer,
    step_number integer,
    step_name character varying(100),
    step_status character varying(50),
    step_error character varying(500),
    step_errignore boolean,
    step_exit_code integer,
    step_started integer,
    step_stopped integer,
    step_version integer,
    step_depends_on text DEFAULT ''::text NOT NULL,
    step_image character varying(1000) DEFAULT ''::character varying NOT NULL,
    step_detached boolean DEFAULT false NOT NULL,
    step_schema character varying(2000) DEFAULT ''::character varying NOT NULL
);


--
-- Name: steps_step_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.steps_step_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: steps_step_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.steps_step_id_seq OWNED BY public.steps.step_id;


--
-- Name: templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates (
    template_id integer NOT NULL,
    template_name text,
    template_namespace character varying(50),
    template_data bytea,
    template_created integer,
    template_updated integer
);


--
-- Name: templates_template_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.templates_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: templates_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.templates_template_id_seq OWNED BY public.templates.template_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    user_login character varying(250),
    user_email character varying(500),
    user_admin boolean,
    user_active boolean,
    user_machine boolean,
    user_avatar character varying(2000),
    user_syncing boolean,
    user_synced integer,
    user_created integer,
    user_updated integer,
    user_last_login integer,
    user_oauth_token bytea,
    user_oauth_refresh bytea,
    user_oauth_expiry integer,
    user_hash character varying(500)
);


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: builds build_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builds ALTER COLUMN build_id SET DEFAULT nextval('public.builds_build_id_seq'::regclass);


--
-- Name: cards card_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards ALTER COLUMN card_id SET DEFAULT nextval('public.cards_card_id_seq'::regclass);


--
-- Name: cron cron_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cron ALTER COLUMN cron_id SET DEFAULT nextval('public.cron_cron_id_seq'::regclass);


--
-- Name: logs log_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logs ALTER COLUMN log_id SET DEFAULT nextval('public.logs_log_id_seq'::regclass);


--
-- Name: nodes node_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nodes ALTER COLUMN node_id SET DEFAULT nextval('public.nodes_node_id_seq'::regclass);


--
-- Name: orgsecrets secret_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orgsecrets ALTER COLUMN secret_id SET DEFAULT nextval('public.orgsecrets_secret_id_seq'::regclass);


--
-- Name: repos repo_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repos ALTER COLUMN repo_id SET DEFAULT nextval('public.repos_repo_id_seq'::regclass);


--
-- Name: secrets secret_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secrets ALTER COLUMN secret_id SET DEFAULT nextval('public.secrets_secret_id_seq'::regclass);


--
-- Name: stages stage_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages ALTER COLUMN stage_id SET DEFAULT nextval('public.stages_stage_id_seq'::regclass);


--
-- Name: steps step_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.steps ALTER COLUMN step_id SET DEFAULT nextval('public.steps_step_id_seq'::regclass);


--
-- Name: templates template_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates ALTER COLUMN template_id SET DEFAULT nextval('public.templates_template_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: builds builds_build_repo_id_build_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builds
    ADD CONSTRAINT builds_build_repo_id_build_number_key UNIQUE (build_repo_id, build_number);


--
-- Name: builds builds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builds
    ADD CONSTRAINT builds_pkey PRIMARY KEY (build_id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (card_id);


--
-- Name: cron cron_cron_repo_id_cron_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cron
    ADD CONSTRAINT cron_cron_repo_id_cron_name_key UNIQUE (cron_repo_id, cron_name);


--
-- Name: cron cron_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cron
    ADD CONSTRAINT cron_pkey PRIMARY KEY (cron_id);


--
-- Name: latest latest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.latest
    ADD CONSTRAINT latest_pkey PRIMARY KEY (latest_repo_id, latest_type, latest_name);


--
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (log_id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: nodes nodes_node_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT nodes_node_name_key UNIQUE (node_name);


--
-- Name: nodes nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT nodes_pkey PRIMARY KEY (node_id);


--
-- Name: orgsecrets orgsecrets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orgsecrets
    ADD CONSTRAINT orgsecrets_pkey PRIMARY KEY (secret_id);


--
-- Name: orgsecrets orgsecrets_secret_namespace_secret_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orgsecrets
    ADD CONSTRAINT orgsecrets_secret_namespace_secret_name_key UNIQUE (secret_namespace, secret_name);


--
-- Name: perms perms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.perms
    ADD CONSTRAINT perms_pkey PRIMARY KEY (perm_user_id, perm_repo_uid);


--
-- Name: repos repos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repos
    ADD CONSTRAINT repos_pkey PRIMARY KEY (repo_id);


--
-- Name: repos repos_repo_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repos
    ADD CONSTRAINT repos_repo_slug_key UNIQUE (repo_slug);


--
-- Name: repos repos_repo_uid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repos
    ADD CONSTRAINT repos_repo_uid_key UNIQUE (repo_uid);


--
-- Name: secrets secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secrets
    ADD CONSTRAINT secrets_pkey PRIMARY KEY (secret_id);


--
-- Name: secrets secrets_secret_repo_id_secret_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secrets
    ADD CONSTRAINT secrets_secret_repo_id_secret_name_key UNIQUE (secret_repo_id, secret_name);


--
-- Name: stages stages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages
    ADD CONSTRAINT stages_pkey PRIMARY KEY (stage_id);


--
-- Name: stages stages_stage_build_id_stage_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages
    ADD CONSTRAINT stages_stage_build_id_stage_number_key UNIQUE (stage_build_id, stage_number);


--
-- Name: steps steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.steps
    ADD CONSTRAINT steps_pkey PRIMARY KEY (step_id);


--
-- Name: steps steps_step_stage_id_step_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.steps
    ADD CONSTRAINT steps_step_stage_id_step_number_key UNIQUE (step_stage_id, step_number);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (template_id);


--
-- Name: templates templates_template_name_template_namespace_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_template_name_template_namespace_key UNIQUE (template_name, template_namespace);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_user_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_hash_key UNIQUE (user_hash);


--
-- Name: users users_user_login_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_login_key UNIQUE (user_login);


--
-- Name: ix_build_author; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_build_author ON public.builds USING btree (build_author);


--
-- Name: ix_build_incomplete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_build_incomplete ON public.builds USING btree (build_status) WHERE ((build_status)::text = ANY ((ARRAY['pending'::character varying, 'running'::character varying])::text[]));


--
-- Name: ix_build_ref; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_build_ref ON public.builds USING btree (build_repo_id, build_ref);


--
-- Name: ix_build_repo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_build_repo ON public.builds USING btree (build_repo_id);


--
-- Name: ix_build_sender; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_build_sender ON public.builds USING btree (build_sender);


--
-- Name: ix_cron_next; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cron_next ON public.cron USING btree (cron_next);


--
-- Name: ix_cron_repo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cron_repo ON public.cron USING btree (cron_repo_id);


--
-- Name: ix_latest_repo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_latest_repo ON public.latest USING btree (latest_repo_id);


--
-- Name: ix_perms_repo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_perms_repo ON public.perms USING btree (perm_repo_uid);


--
-- Name: ix_perms_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_perms_user ON public.perms USING btree (perm_user_id);


--
-- Name: ix_secret_repo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_secret_repo ON public.secrets USING btree (secret_repo_id);


--
-- Name: ix_secret_repo_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_secret_repo_name ON public.secrets USING btree (secret_repo_id, secret_name);


--
-- Name: ix_stage_in_progress; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_stage_in_progress ON public.stages USING btree (stage_status) WHERE ((stage_status)::text = ANY ((ARRAY['pending'::character varying, 'running'::character varying])::text[]));


--
-- Name: ix_stages_build; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_stages_build ON public.stages USING btree (stage_build_id);


--
-- Name: ix_steps_stage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_steps_stage ON public.steps USING btree (step_stage_id);


--
-- Name: ix_template_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_template_namespace ON public.templates USING btree (template_namespace);


--
-- Name: cards cards_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.steps(step_id) ON DELETE CASCADE;


--
-- Name: cron cron_cron_repo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cron
    ADD CONSTRAINT cron_cron_repo_id_fkey FOREIGN KEY (cron_repo_id) REFERENCES public.repos(repo_id) ON DELETE CASCADE;


--
-- Name: secrets secrets_secret_repo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secrets
    ADD CONSTRAINT secrets_secret_repo_id_fkey FOREIGN KEY (secret_repo_id) REFERENCES public.repos(repo_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


