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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: annotation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.annotation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ignore_origin_instance_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ignore_origin_instance_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ignore_origin_user_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ignore_origin_user_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: migration_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migration_versions (
    version character varying(192) NOT NULL,
    executed_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    execution_time integer
);


--
-- Name: oauth2_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth2_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth2_auth_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth2_auth_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth2_clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth2_clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth2_refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth2_refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_credential_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_credential_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tagging_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tagging_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wallabag_annotation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_annotation (
    id integer NOT NULL,
    user_id integer,
    entry_id integer,
    text text NOT NULL,
    created_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    quote text NOT NULL,
    ranges text NOT NULL
);


--
-- Name: COLUMN wallabag_annotation.ranges; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wallabag_annotation.ranges IS '(DC2Type:array)';


--
-- Name: wallabag_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_config (
    id integer NOT NULL,
    user_id integer,
    items_per_page integer NOT NULL,
    language character varying(255) NOT NULL,
    feed_token character varying(255) DEFAULT NULL::character varying,
    feed_limit integer,
    reading_speed double precision,
    pocket_consumer_key character varying(255) DEFAULT NULL::character varying,
    action_mark_as_read integer DEFAULT 0,
    list_mode integer,
    display_thumbnails integer DEFAULT 1
);


--
-- Name: wallabag_entry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_entry (
    id integer NOT NULL,
    user_id integer,
    title text,
    url text,
    is_archived boolean NOT NULL,
    is_starred boolean NOT NULL,
    content text,
    created_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    mimetype text,
    language character varying(20),
    reading_time integer NOT NULL,
    domain_name text,
    preview_picture text,
    uid character varying(23) DEFAULT NULL::character varying,
    http_status character varying(3) DEFAULT NULL::character varying,
    published_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    published_by text,
    headers text,
    starred_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    origin_url text,
    archived_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    hashed_url text,
    given_url text,
    hashed_given_url text
);


--
-- Name: wallabag_entry_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_entry_tag (
    entry_id integer NOT NULL,
    tag_id integer NOT NULL
);


--
-- Name: wallabag_ignore_origin_instance_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_ignore_origin_instance_rule (
    id integer NOT NULL,
    rule character varying(255) NOT NULL
);


--
-- Name: wallabag_ignore_origin_instance_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wallabag_ignore_origin_instance_rule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wallabag_ignore_origin_instance_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wallabag_ignore_origin_instance_rule_id_seq OWNED BY public.wallabag_ignore_origin_instance_rule.id;


--
-- Name: wallabag_ignore_origin_user_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_ignore_origin_user_rule (
    id integer NOT NULL,
    config_id integer NOT NULL,
    rule character varying(255) NOT NULL
);


--
-- Name: wallabag_ignore_origin_user_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wallabag_ignore_origin_user_rule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wallabag_ignore_origin_user_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wallabag_ignore_origin_user_rule_id_seq OWNED BY public.wallabag_ignore_origin_user_rule.id;


--
-- Name: wallabag_internal_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_internal_setting (
    name character varying(255) NOT NULL,
    value character varying(255) DEFAULT NULL::character varying,
    section character varying(255) DEFAULT NULL::character varying
);


--
-- Name: wallabag_oauth2_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_oauth2_access_tokens (
    id integer NOT NULL,
    client_id integer NOT NULL,
    user_id integer,
    token character varying(255) NOT NULL,
    expires_at integer,
    scope character varying(255) DEFAULT NULL::character varying
);


--
-- Name: wallabag_oauth2_auth_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_oauth2_auth_codes (
    id integer NOT NULL,
    client_id integer NOT NULL,
    user_id integer,
    token character varying(255) NOT NULL,
    redirect_uri text NOT NULL,
    expires_at integer,
    scope character varying(255) DEFAULT NULL::character varying
);


--
-- Name: wallabag_oauth2_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_oauth2_clients (
    id integer NOT NULL,
    random_id character varying(255) NOT NULL,
    redirect_uris text NOT NULL,
    secret character varying(255) NOT NULL,
    allowed_grant_types text NOT NULL,
    name bytea NOT NULL,
    user_id integer
);


--
-- Name: COLUMN wallabag_oauth2_clients.redirect_uris; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wallabag_oauth2_clients.redirect_uris IS '(DC2Type:array)';


--
-- Name: COLUMN wallabag_oauth2_clients.allowed_grant_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wallabag_oauth2_clients.allowed_grant_types IS '(DC2Type:array)';


--
-- Name: wallabag_oauth2_refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_oauth2_refresh_tokens (
    id integer NOT NULL,
    client_id integer NOT NULL,
    user_id integer,
    token character varying(255) NOT NULL,
    expires_at integer,
    scope character varying(255) DEFAULT NULL::character varying
);


--
-- Name: wallabag_site_credential; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_site_credential (
    id integer NOT NULL,
    user_id integer NOT NULL,
    host character varying(255) NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    createdat timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone
);


--
-- Name: wallabag_site_credential_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wallabag_site_credential_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wallabag_site_credential_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wallabag_site_credential_id_seq OWNED BY public.wallabag_site_credential.id;


--
-- Name: wallabag_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_tag (
    id integer NOT NULL,
    label text NOT NULL,
    slug character varying(128) NOT NULL
);


--
-- Name: wallabag_tagging_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_tagging_rule (
    id integer NOT NULL,
    config_id integer,
    rule character varying(255) NOT NULL,
    tags text NOT NULL
);


--
-- Name: COLUMN wallabag_tagging_rule.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wallabag_tagging_rule.tags IS '(DC2Type:simple_array)';


--
-- Name: wallabag_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallabag_user (
    id integer NOT NULL,
    username character varying(180) NOT NULL,
    username_canonical character varying(180) NOT NULL,
    email character varying(180) NOT NULL,
    email_canonical character varying(180) NOT NULL,
    enabled boolean NOT NULL,
    salt character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    last_login timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    confirmation_token character varying(255) DEFAULT NULL::character varying,
    password_requested_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    roles text NOT NULL,
    name text,
    created_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    authcode integer,
    emailtwofactor boolean NOT NULL,
    googleauthenticatorsecret character varying(191) DEFAULT NULL::character varying,
    backupcodes json
);


--
-- Name: COLUMN wallabag_user.roles; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wallabag_user.roles IS '(DC2Type:array)';


--
-- Name: wallabag_ignore_origin_instance_rule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_ignore_origin_instance_rule ALTER COLUMN id SET DEFAULT nextval('public.wallabag_ignore_origin_instance_rule_id_seq'::regclass);


--
-- Name: wallabag_ignore_origin_user_rule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_ignore_origin_user_rule ALTER COLUMN id SET DEFAULT nextval('public.wallabag_ignore_origin_user_rule_id_seq'::regclass);


--
-- Name: wallabag_site_credential id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_site_credential ALTER COLUMN id SET DEFAULT nextval('public.wallabag_site_credential_id_seq'::regclass);


--
-- Name: migration_versions migration_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migration_versions
    ADD CONSTRAINT migration_versions_pkey PRIMARY KEY (version);


--
-- Name: wallabag_annotation wallabag_annotation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_annotation
    ADD CONSTRAINT wallabag_annotation_pkey PRIMARY KEY (id);


--
-- Name: wallabag_config wallabag_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_config
    ADD CONSTRAINT wallabag_config_pkey PRIMARY KEY (id);


--
-- Name: wallabag_internal_setting wallabag_craue_config_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_internal_setting
    ADD CONSTRAINT wallabag_craue_config_setting_pkey PRIMARY KEY (name);


--
-- Name: wallabag_entry wallabag_entry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_entry
    ADD CONSTRAINT wallabag_entry_pkey PRIMARY KEY (id);


--
-- Name: wallabag_entry_tag wallabag_entry_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_entry_tag
    ADD CONSTRAINT wallabag_entry_tag_pkey PRIMARY KEY (entry_id, tag_id);


--
-- Name: wallabag_ignore_origin_instance_rule wallabag_ignore_origin_instance_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_ignore_origin_instance_rule
    ADD CONSTRAINT wallabag_ignore_origin_instance_rule_pkey PRIMARY KEY (id);


--
-- Name: wallabag_ignore_origin_user_rule wallabag_ignore_origin_user_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_ignore_origin_user_rule
    ADD CONSTRAINT wallabag_ignore_origin_user_rule_pkey PRIMARY KEY (id);


--
-- Name: wallabag_oauth2_access_tokens wallabag_oauth2_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_oauth2_access_tokens
    ADD CONSTRAINT wallabag_oauth2_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: wallabag_oauth2_auth_codes wallabag_oauth2_auth_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_oauth2_auth_codes
    ADD CONSTRAINT wallabag_oauth2_auth_codes_pkey PRIMARY KEY (id);


--
-- Name: wallabag_oauth2_clients wallabag_oauth2_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_oauth2_clients
    ADD CONSTRAINT wallabag_oauth2_clients_pkey PRIMARY KEY (id);


--
-- Name: wallabag_oauth2_refresh_tokens wallabag_oauth2_refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_oauth2_refresh_tokens
    ADD CONSTRAINT wallabag_oauth2_refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: wallabag_site_credential wallabag_site_credential_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_site_credential
    ADD CONSTRAINT wallabag_site_credential_pkey PRIMARY KEY (id);


--
-- Name: wallabag_tag wallabag_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_tag
    ADD CONSTRAINT wallabag_tag_pkey PRIMARY KEY (id);


--
-- Name: wallabag_tagging_rule wallabag_tagging_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_tagging_rule
    ADD CONSTRAINT wallabag_tagging_rule_pkey PRIMARY KEY (id);


--
-- Name: wallabag_user wallabag_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_user
    ADD CONSTRAINT wallabag_user_pkey PRIMARY KEY (id);


--
-- Name: config_feed_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX config_feed_token ON public.wallabag_config USING btree (feed_token);


--
-- Name: hashed_given_url_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hashed_given_url_user_id ON public.wallabag_entry USING btree (user_id, hashed_given_url);


--
-- Name: hashed_url_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hashed_url_user_id ON public.wallabag_entry USING btree (user_id, hashed_url);


--
-- Name: idx_20c9fb2419eb6921; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_20c9fb2419eb6921 ON public.wallabag_oauth2_refresh_tokens USING btree (client_id);


--
-- Name: idx_20c9fb24a76ed395; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_20c9fb24a76ed395 ON public.wallabag_oauth2_refresh_tokens USING btree (user_id);


--
-- Name: idx_2d9b3c5424db0683; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_2d9b3c5424db0683 ON public.wallabag_tagging_rule USING btree (config_id);


--
-- Name: idx_368a420919eb6921; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_368a420919eb6921 ON public.wallabag_oauth2_access_tokens USING btree (client_id);


--
-- Name: idx_368a4209a76ed395; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_368a4209a76ed395 ON public.wallabag_oauth2_access_tokens USING btree (user_id);


--
-- Name: idx_635d765ea76ed395; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_635d765ea76ed395 ON public.wallabag_oauth2_clients USING btree (user_id);


--
-- Name: idx_a7aed006a76ed395; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_a7aed006a76ed395 ON public.wallabag_annotation USING btree (user_id);


--
-- Name: idx_a7aed006ba364942; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_a7aed006ba364942 ON public.wallabag_annotation USING btree (entry_id);


--
-- Name: idx_c9f0dd7cba364942; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_c9f0dd7cba364942 ON public.wallabag_entry_tag USING btree (entry_id);


--
-- Name: idx_c9f0dd7cbad26311; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_c9f0dd7cbad26311 ON public.wallabag_entry_tag USING btree (tag_id);


--
-- Name: idx_config; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_config ON public.wallabag_ignore_origin_user_rule USING btree (config_id);


--
-- Name: idx_ee52e3fa19eb6921; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ee52e3fa19eb6921 ON public.wallabag_oauth2_auth_codes USING btree (client_id);


--
-- Name: idx_ee52e3faa76ed395; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ee52e3faa76ed395 ON public.wallabag_oauth2_auth_codes USING btree (user_id);


--
-- Name: idx_entry_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_entry_archived ON public.wallabag_entry USING btree (is_archived);


--
-- Name: idx_entry_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_entry_created_at ON public.wallabag_entry USING btree (created_at);


--
-- Name: idx_entry_starred; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_entry_starred ON public.wallabag_entry USING btree (is_starred);


--
-- Name: idx_entry_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_entry_uid ON public.wallabag_entry USING btree (uid);


--
-- Name: idx_f4d18282a76ed395; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_f4d18282a76ed395 ON public.wallabag_entry USING btree (user_id);


--
-- Name: idx_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user ON public.wallabag_site_credential USING btree (user_id);


--
-- Name: tag_label; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tag_label ON public.wallabag_tag USING btree (label);


--
-- Name: uniq_1d63e7e592fc23a8; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_1d63e7e592fc23a8 ON public.wallabag_user USING btree (username_canonical);


--
-- Name: uniq_1d63e7e5a0d96fbf; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_1d63e7e5a0d96fbf ON public.wallabag_user USING btree (email_canonical);


--
-- Name: uniq_1d63e7e5c05fb297; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_1d63e7e5c05fb297 ON public.wallabag_user USING btree (confirmation_token);


--
-- Name: uniq_20c9fb245f37a13b; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_20c9fb245f37a13b ON public.wallabag_oauth2_refresh_tokens USING btree (token);


--
-- Name: uniq_368a42095f37a13b; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_368a42095f37a13b ON public.wallabag_oauth2_access_tokens USING btree (token);


--
-- Name: uniq_4ca58a8c989d9b62; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_4ca58a8c989d9b62 ON public.wallabag_tag USING btree (slug);


--
-- Name: uniq_5d9649505e237e06; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_5d9649505e237e06 ON public.wallabag_internal_setting USING btree (name);


--
-- Name: uniq_87e64c53a76ed395; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_87e64c53a76ed395 ON public.wallabag_config USING btree (user_id);


--
-- Name: uniq_ee52e3fa5f37a13b; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_ee52e3fa5f37a13b ON public.wallabag_oauth2_auth_codes USING btree (token);


--
-- Name: user_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_archived ON public.wallabag_entry USING btree (user_id, is_archived, archived_at);


--
-- Name: user_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_created ON public.wallabag_entry USING btree (user_id, created_at);


--
-- Name: user_language; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_language ON public.wallabag_entry USING btree (language, user_id);


--
-- Name: user_starred; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_starred ON public.wallabag_entry USING btree (user_id, is_starred, starred_at);


--
-- Name: wallabag_oauth2_refresh_tokens fk_20c9fb2419eb6921; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_oauth2_refresh_tokens
    ADD CONSTRAINT fk_20c9fb2419eb6921 FOREIGN KEY (client_id) REFERENCES public.wallabag_oauth2_clients(id);


--
-- Name: wallabag_oauth2_refresh_tokens fk_20c9fb24a76ed395; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_oauth2_refresh_tokens
    ADD CONSTRAINT fk_20c9fb24a76ed395 FOREIGN KEY (user_id) REFERENCES public.wallabag_user(id) ON DELETE CASCADE;


--
-- Name: wallabag_tagging_rule fk_2d9b3c5424db0683; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_tagging_rule
    ADD CONSTRAINT fk_2d9b3c5424db0683 FOREIGN KEY (config_id) REFERENCES public.wallabag_config(id);


--
-- Name: wallabag_oauth2_access_tokens fk_368a420919eb6921; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_oauth2_access_tokens
    ADD CONSTRAINT fk_368a420919eb6921 FOREIGN KEY (client_id) REFERENCES public.wallabag_oauth2_clients(id);


--
-- Name: wallabag_oauth2_access_tokens fk_368a4209a76ed395; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_oauth2_access_tokens
    ADD CONSTRAINT fk_368a4209a76ed395 FOREIGN KEY (user_id) REFERENCES public.wallabag_user(id) ON DELETE CASCADE;


--
-- Name: wallabag_oauth2_clients fk_635d765ea76ed395; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_oauth2_clients
    ADD CONSTRAINT fk_635d765ea76ed395 FOREIGN KEY (user_id) REFERENCES public.wallabag_user(id);


--
-- Name: wallabag_config fk_87e64c53a76ed395; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_config
    ADD CONSTRAINT fk_87e64c53a76ed395 FOREIGN KEY (user_id) REFERENCES public.wallabag_user(id);


--
-- Name: wallabag_annotation fk_a7aed006a76ed395; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_annotation
    ADD CONSTRAINT fk_a7aed006a76ed395 FOREIGN KEY (user_id) REFERENCES public.wallabag_user(id);


--
-- Name: wallabag_annotation fk_annotation_entry; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_annotation
    ADD CONSTRAINT fk_annotation_entry FOREIGN KEY (entry_id) REFERENCES public.wallabag_entry(id) ON DELETE CASCADE;


--
-- Name: wallabag_ignore_origin_user_rule fk_config; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_ignore_origin_user_rule
    ADD CONSTRAINT fk_config FOREIGN KEY (config_id) REFERENCES public.wallabag_config(id);


--
-- Name: wallabag_oauth2_auth_codes fk_ee52e3fa19eb6921; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_oauth2_auth_codes
    ADD CONSTRAINT fk_ee52e3fa19eb6921 FOREIGN KEY (client_id) REFERENCES public.wallabag_oauth2_clients(id);


--
-- Name: wallabag_oauth2_auth_codes fk_ee52e3faa76ed395; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_oauth2_auth_codes
    ADD CONSTRAINT fk_ee52e3faa76ed395 FOREIGN KEY (user_id) REFERENCES public.wallabag_user(id) ON DELETE CASCADE;


--
-- Name: wallabag_entry_tag fk_entry_tag_entry; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_entry_tag
    ADD CONSTRAINT fk_entry_tag_entry FOREIGN KEY (entry_id) REFERENCES public.wallabag_entry(id) ON DELETE CASCADE;


--
-- Name: wallabag_entry_tag fk_entry_tag_tag; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_entry_tag
    ADD CONSTRAINT fk_entry_tag_tag FOREIGN KEY (tag_id) REFERENCES public.wallabag_tag(id) ON DELETE CASCADE;


--
-- Name: wallabag_entry fk_f4d18282a76ed395; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_entry
    ADD CONSTRAINT fk_f4d18282a76ed395 FOREIGN KEY (user_id) REFERENCES public.wallabag_user(id);


--
-- Name: wallabag_site_credential fk_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallabag_site_credential
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.wallabag_user(id);


--
-- PostgreSQL database dump complete
--


