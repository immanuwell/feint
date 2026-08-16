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
-- Name: freshrss_admin_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.freshrss_admin_category (
    id integer NOT NULL,
    name character varying(191) NOT NULL,
    kind smallint DEFAULT 0,
    "lastUpdate" bigint DEFAULT 0,
    error bigint DEFAULT 0,
    attributes text
);


--
-- Name: freshrss_admin_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.freshrss_admin_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: freshrss_admin_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.freshrss_admin_category_id_seq OWNED BY public.freshrss_admin_category.id;


--
-- Name: freshrss_admin_entry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.freshrss_admin_entry (
    id bigint NOT NULL,
    guid character varying(767) NOT NULL,
    title character varying(8192) NOT NULL,
    author character varying(1024),
    content text,
    link character varying(16383) NOT NULL,
    date bigint,
    "lastSeen" bigint DEFAULT 0,
    "lastModified" bigint,
    "lastUserModified" bigint,
    hash bytea,
    is_read smallint DEFAULT 0 NOT NULL,
    is_favorite smallint DEFAULT 0 NOT NULL,
    id_feed integer,
    tags character varying(2048),
    attributes text
);


--
-- Name: freshrss_admin_entrytag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.freshrss_admin_entrytag (
    id_tag integer NOT NULL,
    id_entry bigint NOT NULL
);


--
-- Name: freshrss_admin_entrytmp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.freshrss_admin_entrytmp (
    id bigint NOT NULL,
    guid character varying(767) NOT NULL,
    title character varying(8192) NOT NULL,
    author character varying(1024),
    content text,
    link character varying(16383) NOT NULL,
    date bigint,
    "lastSeen" bigint DEFAULT 0,
    hash bytea,
    is_read smallint DEFAULT 0 NOT NULL,
    is_favorite smallint DEFAULT 0 NOT NULL,
    id_feed integer,
    tags character varying(2048),
    attributes text
);


--
-- Name: freshrss_admin_feed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.freshrss_admin_feed (
    id integer NOT NULL,
    url character varying(32768) NOT NULL,
    kind smallint DEFAULT 0,
    category integer DEFAULT 0,
    name character varying(191) NOT NULL,
    website character varying(32768),
    description text,
    "lastUpdate" bigint DEFAULT 0,
    priority smallint DEFAULT 10 NOT NULL,
    "pathEntries" character varying(4096) DEFAULT NULL::character varying,
    "httpAuth" character varying(1024) DEFAULT NULL::character varying,
    error bigint DEFAULT 0,
    ttl integer DEFAULT 0 NOT NULL,
    attributes text,
    "cache_nbEntries" integer DEFAULT 0,
    "cache_nbUnreads" integer DEFAULT 0
);


--
-- Name: freshrss_admin_feed_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.freshrss_admin_feed_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: freshrss_admin_feed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.freshrss_admin_feed_id_seq OWNED BY public.freshrss_admin_feed.id;


--
-- Name: freshrss_admin_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.freshrss_admin_tag (
    id integer NOT NULL,
    name character varying(191) NOT NULL,
    attributes text
);


--
-- Name: freshrss_admin_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.freshrss_admin_tag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: freshrss_admin_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.freshrss_admin_tag_id_seq OWNED BY public.freshrss_admin_tag.id;


--
-- Name: freshrss_admin_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_category ALTER COLUMN id SET DEFAULT nextval('public.freshrss_admin_category_id_seq'::regclass);


--
-- Name: freshrss_admin_feed id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_feed ALTER COLUMN id SET DEFAULT nextval('public.freshrss_admin_feed_id_seq'::regclass);


--
-- Name: freshrss_admin_tag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_tag ALTER COLUMN id SET DEFAULT nextval('public.freshrss_admin_tag_id_seq'::regclass);


--
-- Name: freshrss_admin_category freshrss_admin_category_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_category
    ADD CONSTRAINT freshrss_admin_category_name_key UNIQUE (name);


--
-- Name: freshrss_admin_category freshrss_admin_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_category
    ADD CONSTRAINT freshrss_admin_category_pkey PRIMARY KEY (id);


--
-- Name: freshrss_admin_entry freshrss_admin_entry_id_feed_guid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_entry
    ADD CONSTRAINT freshrss_admin_entry_id_feed_guid_key UNIQUE (id_feed, guid);


--
-- Name: freshrss_admin_entry freshrss_admin_entry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_entry
    ADD CONSTRAINT freshrss_admin_entry_pkey PRIMARY KEY (id);


--
-- Name: freshrss_admin_entrytag freshrss_admin_entrytag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_entrytag
    ADD CONSTRAINT freshrss_admin_entrytag_pkey PRIMARY KEY (id_tag, id_entry);


--
-- Name: freshrss_admin_entrytmp freshrss_admin_entrytmp_id_feed_guid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_entrytmp
    ADD CONSTRAINT freshrss_admin_entrytmp_id_feed_guid_key UNIQUE (id_feed, guid);


--
-- Name: freshrss_admin_entrytmp freshrss_admin_entrytmp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_entrytmp
    ADD CONSTRAINT freshrss_admin_entrytmp_pkey PRIMARY KEY (id);


--
-- Name: freshrss_admin_feed freshrss_admin_feed_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_feed
    ADD CONSTRAINT freshrss_admin_feed_pkey PRIMARY KEY (id);


--
-- Name: freshrss_admin_tag freshrss_admin_tag_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_tag
    ADD CONSTRAINT freshrss_admin_tag_name_key UNIQUE (name);


--
-- Name: freshrss_admin_tag freshrss_admin_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_tag
    ADD CONSTRAINT freshrss_admin_tag_pkey PRIMARY KEY (id);


--
-- Name: freshrss_admin_entry_feed_read_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX freshrss_admin_entry_feed_read_index ON public.freshrss_admin_entry USING btree (id_feed, is_read);


--
-- Name: freshrss_admin_entry_lastSeen_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "freshrss_admin_entry_lastSeen_index" ON public.freshrss_admin_entry USING btree ("lastSeen");


--
-- Name: freshrss_admin_entry_last_modified_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX freshrss_admin_entry_last_modified_index ON public.freshrss_admin_entry USING btree ("lastModified");


--
-- Name: freshrss_admin_entry_last_user_modified_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX freshrss_admin_entry_last_user_modified_index ON public.freshrss_admin_entry USING btree ("lastUserModified");


--
-- Name: freshrss_admin_entrytag_id_entry_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX freshrss_admin_entrytag_id_entry_index ON public.freshrss_admin_entrytag USING btree (id_entry);


--
-- Name: freshrss_admin_entrytmp_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX freshrss_admin_entrytmp_date_index ON public.freshrss_admin_entrytmp USING btree (date);


--
-- Name: freshrss_admin_is_favorite_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX freshrss_admin_is_favorite_index ON public.freshrss_admin_entry USING btree (is_favorite);


--
-- Name: freshrss_admin_is_read_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX freshrss_admin_is_read_index ON public.freshrss_admin_entry USING btree (is_read);


--
-- Name: freshrss_admin_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX freshrss_admin_name_index ON public.freshrss_admin_feed USING btree (name);


--
-- Name: freshrss_admin_priority_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX freshrss_admin_priority_index ON public.freshrss_admin_feed USING btree (priority);


--
-- Name: freshrss_admin_entry freshrss_admin_entry_id_feed_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_entry
    ADD CONSTRAINT freshrss_admin_entry_id_feed_fkey FOREIGN KEY (id_feed) REFERENCES public.freshrss_admin_feed(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: freshrss_admin_entrytag freshrss_admin_entrytag_id_entry_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_entrytag
    ADD CONSTRAINT freshrss_admin_entrytag_id_entry_fkey FOREIGN KEY (id_entry) REFERENCES public.freshrss_admin_entry(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: freshrss_admin_entrytag freshrss_admin_entrytag_id_tag_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_entrytag
    ADD CONSTRAINT freshrss_admin_entrytag_id_tag_fkey FOREIGN KEY (id_tag) REFERENCES public.freshrss_admin_tag(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: freshrss_admin_entrytmp freshrss_admin_entrytmp_id_feed_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_entrytmp
    ADD CONSTRAINT freshrss_admin_entrytmp_id_feed_fkey FOREIGN KEY (id_feed) REFERENCES public.freshrss_admin_feed(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: freshrss_admin_feed freshrss_admin_feed_category_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.freshrss_admin_feed
    ADD CONSTRAINT freshrss_admin_feed_category_fkey FOREIGN KEY (category) REFERENCES public.freshrss_admin_category(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--


