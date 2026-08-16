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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Name: app_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_setting (
    key text NOT NULL,
    value text NOT NULL
);


--
-- Name: board; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.board (
    board_id uuid NOT NULL,
    type character varying(50) NOT NULL,
    name character varying(200) NOT NULL,
    description character varying(500) NOT NULL,
    parameters jsonb NOT NULL,
    user_id uuid,
    team_id uuid,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(6) with time zone
);


--
-- Name: event_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_data (
    event_data_id uuid NOT NULL,
    website_id uuid NOT NULL,
    website_event_id uuid NOT NULL,
    data_key character varying(500) NOT NULL,
    string_value character varying(500),
    number_value numeric(19,4),
    date_value timestamp(6) with time zone,
    data_type integer NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: heatmap_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heatmap_event (
    heatmap_event_id uuid NOT NULL,
    website_id uuid NOT NULL,
    session_id uuid NOT NULL,
    visit_id uuid NOT NULL,
    url_path character varying(500) NOT NULL,
    event_type integer NOT NULL,
    x integer,
    y integer,
    page_x integer,
    page_y integer,
    page_w integer,
    viewport_w integer,
    viewport_h integer,
    page_h integer,
    scroll_pct integer,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: link; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.link (
    link_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    url character varying(500) NOT NULL,
    slug character varying(100) NOT NULL,
    user_id uuid,
    team_id uuid,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(6) with time zone,
    deleted_at timestamp(6) with time zone
);


--
-- Name: pixel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pixel (
    pixel_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    user_id uuid,
    team_id uuid,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(6) with time zone,
    deleted_at timestamp(6) with time zone
);


--
-- Name: report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report (
    report_id uuid NOT NULL,
    user_id uuid NOT NULL,
    website_id uuid NOT NULL,
    type character varying(50) NOT NULL,
    name character varying(200) NOT NULL,
    description character varying(500) NOT NULL,
    parameters jsonb NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(6) with time zone
);


--
-- Name: revenue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.revenue (
    revenue_id uuid NOT NULL,
    website_id uuid NOT NULL,
    session_id uuid NOT NULL,
    event_id uuid NOT NULL,
    event_name character varying(50) NOT NULL,
    currency character varying(10) NOT NULL,
    revenue numeric(19,4),
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: segment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.segment (
    segment_id uuid NOT NULL,
    website_id uuid NOT NULL,
    type character varying(50) NOT NULL,
    name character varying(200) NOT NULL,
    parameters jsonb NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(6) with time zone
);


--
-- Name: session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session (
    session_id uuid NOT NULL,
    website_id uuid NOT NULL,
    browser character varying(20),
    os character varying(20),
    device character varying(20),
    screen character varying(11),
    language character varying(35),
    country character(2),
    region character varying(20),
    city character varying(50),
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    distinct_id character varying(50)
);


--
-- Name: session_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_data (
    session_data_id uuid NOT NULL,
    website_id uuid NOT NULL,
    session_id uuid NOT NULL,
    data_key character varying(500) NOT NULL,
    string_value character varying(500),
    number_value numeric(19,4),
    date_value timestamp(6) with time zone,
    data_type integer NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    distinct_id character varying(50)
);


--
-- Name: session_link; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_link (
    website_id uuid NOT NULL,
    session_id uuid NOT NULL,
    distinct_id character varying(50) NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: session_replay; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_replay (
    replay_id uuid NOT NULL,
    website_id uuid NOT NULL,
    session_id uuid NOT NULL,
    visit_id uuid NOT NULL,
    chunk_index integer NOT NULL,
    events bytea NOT NULL,
    event_count integer NOT NULL,
    started_at timestamp(6) with time zone NOT NULL,
    ended_at timestamp(6) with time zone NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: session_replay_saved; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_replay_saved (
    saved_replay_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    website_id uuid NOT NULL,
    visit_id uuid NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(6) with time zone
);


--
-- Name: share; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.share (
    share_id uuid NOT NULL,
    entity_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    share_type integer NOT NULL,
    slug character varying(100) NOT NULL,
    parameters jsonb NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(6) with time zone
);


--
-- Name: team; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team (
    team_id uuid NOT NULL,
    name character varying(50) NOT NULL,
    access_code character varying(50),
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(6) with time zone,
    deleted_at timestamp(6) with time zone,
    logo_url character varying(2183),
    two_factor_required boolean DEFAULT false NOT NULL
);


--
-- Name: team_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_user (
    team_user_id uuid NOT NULL,
    team_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role character varying(50) NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(6) with time zone
);


--
-- Name: two_factor_auth; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.two_factor_auth (
    id text NOT NULL,
    user_id uuid NOT NULL,
    secret text NOT NULL,
    is_enabled boolean DEFAULT false NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: two_factor_backup_code; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.two_factor_backup_code (
    id text NOT NULL,
    user_id uuid NOT NULL,
    code_hash text NOT NULL,
    used boolean DEFAULT false NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: two_factor_otp_used; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.two_factor_otp_used (
    id text NOT NULL,
    user_id uuid NOT NULL,
    otp text NOT NULL,
    expires_at timestamp(6) with time zone NOT NULL
);


--
-- Name: two_factor_rate_limit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.two_factor_rate_limit (
    id text NOT NULL,
    user_id uuid NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    locked_until timestamp(6) with time zone,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    user_id uuid NOT NULL,
    username character varying(255) NOT NULL,
    password character varying(60) NOT NULL,
    role character varying(50) NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(6) with time zone,
    deleted_at timestamp(6) with time zone,
    display_name character varying(255),
    logo_url character varying(2183),
    two_factor_required boolean DEFAULT false NOT NULL
);


--
-- Name: website; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.website (
    website_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    domain character varying(500),
    reset_at timestamp(6) with time zone,
    user_id uuid,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(6) with time zone,
    deleted_at timestamp(6) with time zone,
    created_by uuid,
    team_id uuid,
    recorder_enabled boolean DEFAULT false NOT NULL,
    replay_config jsonb
);


--
-- Name: website_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.website_event (
    event_id uuid NOT NULL,
    website_id uuid NOT NULL,
    session_id uuid NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    url_path character varying(500) NOT NULL,
    url_query character varying(500),
    referrer_path character varying(500),
    referrer_query character varying(500),
    referrer_domain character varying(500),
    page_title character varying(500),
    event_type integer DEFAULT 1 NOT NULL,
    event_name character varying(50),
    visit_id uuid NOT NULL,
    tag character varying(50),
    fbclid character varying(255),
    gclid character varying(255),
    li_fat_id character varying(255),
    msclkid character varying(255),
    ttclid character varying(255),
    twclid character varying(255),
    utm_campaign character varying(255),
    utm_content character varying(255),
    utm_medium character varying(255),
    utm_source character varying(255),
    utm_term character varying(255),
    hostname character varying(100),
    cls numeric(10,4),
    fcp numeric(10,1),
    inp numeric(10,1),
    lcp numeric(10,1),
    ttfb numeric(10,1)
);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: app_setting app_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_setting
    ADD CONSTRAINT app_setting_pkey PRIMARY KEY (key);


--
-- Name: board board_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.board
    ADD CONSTRAINT board_pkey PRIMARY KEY (board_id);


--
-- Name: event_data event_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_data
    ADD CONSTRAINT event_data_pkey PRIMARY KEY (event_data_id);


--
-- Name: heatmap_event heatmap_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heatmap_event
    ADD CONSTRAINT heatmap_event_pkey PRIMARY KEY (heatmap_event_id);


--
-- Name: link link_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_pkey PRIMARY KEY (link_id);


--
-- Name: pixel pixel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pixel
    ADD CONSTRAINT pixel_pkey PRIMARY KEY (pixel_id);


--
-- Name: report report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT report_pkey PRIMARY KEY (report_id);


--
-- Name: revenue revenue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revenue
    ADD CONSTRAINT revenue_pkey PRIMARY KEY (revenue_id);


--
-- Name: segment segment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.segment
    ADD CONSTRAINT segment_pkey PRIMARY KEY (segment_id);


--
-- Name: session_data session_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_data
    ADD CONSTRAINT session_data_pkey PRIMARY KEY (session_data_id);


--
-- Name: session_link session_link_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_link
    ADD CONSTRAINT session_link_pkey PRIMARY KEY (website_id, distinct_id, session_id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (session_id);


--
-- Name: session_replay session_replay_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_replay
    ADD CONSTRAINT session_replay_pkey PRIMARY KEY (replay_id);


--
-- Name: session_replay_saved session_replay_saved_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_replay_saved
    ADD CONSTRAINT session_replay_saved_pkey PRIMARY KEY (saved_replay_id);


--
-- Name: session_replay_saved session_replay_saved_website_id_visit_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_replay_saved
    ADD CONSTRAINT session_replay_saved_website_id_visit_id_key UNIQUE (website_id, visit_id);


--
-- Name: share share_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share
    ADD CONSTRAINT share_pkey PRIMARY KEY (share_id);


--
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (team_id);


--
-- Name: team_user team_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_user
    ADD CONSTRAINT team_user_pkey PRIMARY KEY (team_user_id);


--
-- Name: two_factor_auth two_factor_auth_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.two_factor_auth
    ADD CONSTRAINT two_factor_auth_pkey PRIMARY KEY (id);


--
-- Name: two_factor_backup_code two_factor_backup_code_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.two_factor_backup_code
    ADD CONSTRAINT two_factor_backup_code_pkey PRIMARY KEY (id);


--
-- Name: two_factor_otp_used two_factor_otp_used_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.two_factor_otp_used
    ADD CONSTRAINT two_factor_otp_used_pkey PRIMARY KEY (id);


--
-- Name: two_factor_rate_limit two_factor_rate_limit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.two_factor_rate_limit
    ADD CONSTRAINT two_factor_rate_limit_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (user_id);


--
-- Name: website_event website_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.website_event
    ADD CONSTRAINT website_event_pkey PRIMARY KEY (event_id);


--
-- Name: website website_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.website
    ADD CONSTRAINT website_pkey PRIMARY KEY (website_id);


--
-- Name: board_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX board_created_at_idx ON public.board USING btree (created_at);


--
-- Name: board_team_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX board_team_id_idx ON public.board USING btree (team_id);


--
-- Name: board_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX board_user_id_idx ON public.board USING btree (user_id);


--
-- Name: event_data_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_data_created_at_idx ON public.event_data USING btree (created_at);


--
-- Name: event_data_website_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_data_website_event_id_idx ON public.event_data USING btree (website_event_id);


--
-- Name: event_data_website_id_created_at_data_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_data_website_id_created_at_data_key_idx ON public.event_data USING btree (website_id, created_at, data_key);


--
-- Name: event_data_website_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_data_website_id_created_at_idx ON public.event_data USING btree (website_id, created_at);


--
-- Name: event_data_website_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_data_website_id_idx ON public.event_data USING btree (website_id);


--
-- Name: heatmap_event_visit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX heatmap_event_visit_id_idx ON public.heatmap_event USING btree (visit_id);


--
-- Name: heatmap_event_website_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX heatmap_event_website_id_created_at_idx ON public.heatmap_event USING btree (website_id, created_at);


--
-- Name: heatmap_event_website_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX heatmap_event_website_id_idx ON public.heatmap_event USING btree (website_id);


--
-- Name: heatmap_event_website_id_url_path_event_type_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX heatmap_event_website_id_url_path_event_type_created_at_idx ON public.heatmap_event USING btree (website_id, url_path, event_type, created_at);


--
-- Name: link_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX link_created_at_idx ON public.link USING btree (created_at);


--
-- Name: link_slug_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX link_slug_idx ON public.link USING btree (slug);


--
-- Name: link_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX link_slug_key ON public.link USING btree (slug);


--
-- Name: link_team_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX link_team_id_idx ON public.link USING btree (team_id);


--
-- Name: link_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX link_user_id_idx ON public.link USING btree (user_id);


--
-- Name: pixel_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pixel_created_at_idx ON public.pixel USING btree (created_at);


--
-- Name: pixel_slug_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pixel_slug_idx ON public.pixel USING btree (slug);


--
-- Name: pixel_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX pixel_slug_key ON public.pixel USING btree (slug);


--
-- Name: pixel_team_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pixel_team_id_idx ON public.pixel USING btree (team_id);


--
-- Name: pixel_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pixel_user_id_idx ON public.pixel USING btree (user_id);


--
-- Name: report_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX report_name_idx ON public.report USING btree (name);


--
-- Name: report_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX report_type_idx ON public.report USING btree (type);


--
-- Name: report_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX report_user_id_idx ON public.report USING btree (user_id);


--
-- Name: report_website_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX report_website_id_idx ON public.report USING btree (website_id);


--
-- Name: revenue_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX revenue_session_id_idx ON public.revenue USING btree (session_id);


--
-- Name: revenue_website_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX revenue_website_id_created_at_idx ON public.revenue USING btree (website_id, created_at);


--
-- Name: revenue_website_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX revenue_website_id_idx ON public.revenue USING btree (website_id);


--
-- Name: revenue_website_id_session_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX revenue_website_id_session_id_created_at_idx ON public.revenue USING btree (website_id, session_id, created_at);


--
-- Name: segment_website_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX segment_website_id_idx ON public.segment USING btree (website_id);


--
-- Name: session_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_created_at_idx ON public.session USING btree (created_at);


--
-- Name: session_data_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_data_created_at_idx ON public.session_data USING btree (created_at);


--
-- Name: session_data_session_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_data_session_id_created_at_idx ON public.session_data USING btree (session_id, created_at);


--
-- Name: session_data_session_id_data_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX session_data_session_id_data_key_key ON public.session_data USING btree (session_id, data_key);


--
-- Name: session_data_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_data_session_id_idx ON public.session_data USING btree (session_id);


--
-- Name: session_data_website_id_created_at_data_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_data_website_id_created_at_data_key_idx ON public.session_data USING btree (website_id, created_at, data_key);


--
-- Name: session_data_website_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_data_website_id_idx ON public.session_data USING btree (website_id);


--
-- Name: session_link_website_id_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_link_website_id_session_id_idx ON public.session_link USING btree (website_id, session_id);


--
-- Name: session_replay_saved_visit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_replay_saved_visit_id_idx ON public.session_replay_saved USING btree (visit_id);


--
-- Name: session_replay_saved_website_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_replay_saved_website_id_created_at_idx ON public.session_replay_saved USING btree (website_id, created_at);


--
-- Name: session_replay_saved_website_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_replay_saved_website_id_idx ON public.session_replay_saved USING btree (website_id);


--
-- Name: session_replay_session_id_chunk_index_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_replay_session_id_chunk_index_idx ON public.session_replay USING btree (session_id, chunk_index);


--
-- Name: session_replay_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_replay_session_id_idx ON public.session_replay USING btree (session_id);


--
-- Name: session_replay_visit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_replay_visit_id_idx ON public.session_replay USING btree (visit_id);


--
-- Name: session_replay_website_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_replay_website_id_created_at_idx ON public.session_replay USING btree (website_id, created_at);


--
-- Name: session_replay_website_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_replay_website_id_idx ON public.session_replay USING btree (website_id);


--
-- Name: session_replay_website_id_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_replay_website_id_session_id_idx ON public.session_replay USING btree (website_id, session_id);


--
-- Name: session_replay_website_id_visit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_replay_website_id_visit_id_idx ON public.session_replay USING btree (website_id, visit_id);


--
-- Name: session_website_id_created_at_browser_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_website_id_created_at_browser_idx ON public.session USING btree (website_id, created_at, browser);


--
-- Name: session_website_id_created_at_city_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_website_id_created_at_city_idx ON public.session USING btree (website_id, created_at, city);


--
-- Name: session_website_id_created_at_country_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_website_id_created_at_country_idx ON public.session USING btree (website_id, created_at, country);


--
-- Name: session_website_id_created_at_device_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_website_id_created_at_device_idx ON public.session USING btree (website_id, created_at, device);


--
-- Name: session_website_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_website_id_created_at_idx ON public.session USING btree (website_id, created_at);


--
-- Name: session_website_id_created_at_language_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_website_id_created_at_language_idx ON public.session USING btree (website_id, created_at, language);


--
-- Name: session_website_id_created_at_os_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_website_id_created_at_os_idx ON public.session USING btree (website_id, created_at, os);


--
-- Name: session_website_id_created_at_region_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_website_id_created_at_region_idx ON public.session USING btree (website_id, created_at, region);


--
-- Name: session_website_id_created_at_screen_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_website_id_created_at_screen_idx ON public.session USING btree (website_id, created_at, screen);


--
-- Name: session_website_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_website_id_idx ON public.session USING btree (website_id);


--
-- Name: share_entity_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX share_entity_id_idx ON public.share USING btree (entity_id);


--
-- Name: share_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX share_slug_key ON public.share USING btree (slug);


--
-- Name: team_access_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX team_access_code_idx ON public.team USING btree (access_code);


--
-- Name: team_access_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX team_access_code_key ON public.team USING btree (access_code);


--
-- Name: team_user_team_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX team_user_team_id_idx ON public.team_user USING btree (team_id);


--
-- Name: team_user_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX team_user_user_id_idx ON public.team_user USING btree (user_id);


--
-- Name: two_factor_auth_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX two_factor_auth_user_id_key ON public.two_factor_auth USING btree (user_id);


--
-- Name: two_factor_backup_code_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX two_factor_backup_code_user_id_idx ON public.two_factor_backup_code USING btree (user_id);


--
-- Name: two_factor_otp_used_user_id_otp_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX two_factor_otp_used_user_id_otp_key ON public.two_factor_otp_used USING btree (user_id, otp);


--
-- Name: two_factor_rate_limit_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX two_factor_rate_limit_user_id_key ON public.two_factor_rate_limit USING btree (user_id);


--
-- Name: user_username_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_username_key ON public."user" USING btree (username);


--
-- Name: website_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_created_at_idx ON public.website USING btree (created_at);


--
-- Name: website_created_by_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_created_by_idx ON public.website USING btree (created_by);


--
-- Name: website_event_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_created_at_idx ON public.website_event USING btree (created_at);


--
-- Name: website_event_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_session_id_idx ON public.website_event USING btree (session_id);


--
-- Name: website_event_visit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_visit_id_idx ON public.website_event USING btree (visit_id);


--
-- Name: website_event_website_id_created_at_event_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_website_id_created_at_event_name_idx ON public.website_event USING btree (website_id, created_at, event_name);


--
-- Name: website_event_website_id_created_at_hostname_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_website_id_created_at_hostname_idx ON public.website_event USING btree (website_id, created_at, hostname);


--
-- Name: website_event_website_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_website_id_created_at_idx ON public.website_event USING btree (website_id, created_at);


--
-- Name: website_event_website_id_created_at_page_title_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_website_id_created_at_page_title_idx ON public.website_event USING btree (website_id, created_at, page_title);


--
-- Name: website_event_website_id_created_at_referrer_domain_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_website_id_created_at_referrer_domain_idx ON public.website_event USING btree (website_id, created_at, referrer_domain);


--
-- Name: website_event_website_id_created_at_tag_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_website_id_created_at_tag_idx ON public.website_event USING btree (website_id, created_at, tag);


--
-- Name: website_event_website_id_created_at_url_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_website_id_created_at_url_path_idx ON public.website_event USING btree (website_id, created_at, url_path);


--
-- Name: website_event_website_id_created_at_url_query_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_website_id_created_at_url_query_idx ON public.website_event USING btree (website_id, created_at, url_query);


--
-- Name: website_event_website_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_website_id_idx ON public.website_event USING btree (website_id);


--
-- Name: website_event_website_id_session_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_website_id_session_id_created_at_idx ON public.website_event USING btree (website_id, session_id, created_at);


--
-- Name: website_event_website_id_visit_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_event_website_id_visit_id_created_at_idx ON public.website_event USING btree (website_id, visit_id, created_at);


--
-- Name: website_team_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_team_id_idx ON public.website USING btree (team_id);


--
-- Name: website_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX website_user_id_idx ON public.website USING btree (user_id);


--
-- PostgreSQL database dump complete
--


