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
-- Name: legacy_object_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.legacy_object_type AS ENUM (
    'hash',
    'zset',
    'set',
    'list',
    'string'
);


--
-- Name: nodebb_get_sorted_set_members(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.nodebb_get_sorted_set_members(text) RETURNS text[]
    LANGUAGE sql STABLE STRICT PARALLEL SAFE
    AS $_$
    SELECT array_agg(z."value" ORDER BY z."score" ASC)
      FROM "legacy_object_live" o
     INNER JOIN "legacy_zset" z
             ON o."_key" = z."_key"
            AND o."type" = z."type"
          WHERE o."_key" = $1
$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: legacy_hash; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_hash (
    _key text NOT NULL,
    data jsonb NOT NULL,
    type public.legacy_object_type DEFAULT 'hash'::public.legacy_object_type NOT NULL,
    CONSTRAINT legacy_hash_type_check CHECK ((type = 'hash'::public.legacy_object_type))
);


--
-- Name: legacy_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_list (
    _key text NOT NULL,
    "array" text[] NOT NULL,
    type public.legacy_object_type DEFAULT 'list'::public.legacy_object_type NOT NULL,
    CONSTRAINT legacy_list_type_check CHECK ((type = 'list'::public.legacy_object_type))
);


--
-- Name: legacy_object; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_object (
    _key text NOT NULL,
    type public.legacy_object_type NOT NULL,
    "expireAt" timestamp with time zone
);


--
-- Name: legacy_object_live; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.legacy_object_live AS
 SELECT _key,
    type
   FROM public.legacy_object
  WHERE (("expireAt" IS NULL) OR ("expireAt" > CURRENT_TIMESTAMP));


--
-- Name: legacy_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_set (
    _key text NOT NULL,
    member text NOT NULL,
    type public.legacy_object_type DEFAULT 'set'::public.legacy_object_type NOT NULL,
    CONSTRAINT legacy_set_type_check CHECK ((type = 'set'::public.legacy_object_type))
);


--
-- Name: legacy_string; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_string (
    _key text NOT NULL,
    data text NOT NULL,
    type public.legacy_object_type DEFAULT 'string'::public.legacy_object_type NOT NULL,
    CONSTRAINT legacy_string_type_check CHECK ((type = 'string'::public.legacy_object_type))
);


--
-- Name: legacy_zset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_zset (
    _key text NOT NULL,
    value text NOT NULL,
    score numeric NOT NULL,
    type public.legacy_object_type DEFAULT 'zset'::public.legacy_object_type NOT NULL,
    CONSTRAINT legacy_zset_type_check CHECK ((type = 'zset'::public.legacy_object_type))
);


--
-- Name: session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session (
    sid character(32) NOT NULL COLLATE pg_catalog."C",
    sess jsonb NOT NULL,
    expire timestamp with time zone NOT NULL
);
ALTER TABLE ONLY public.session ALTER COLUMN sid SET STORAGE MAIN;


--
-- Name: legacy_hash legacy_hash_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_hash
    ADD CONSTRAINT legacy_hash_pkey PRIMARY KEY (_key);


--
-- Name: legacy_list legacy_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_list
    ADD CONSTRAINT legacy_list_pkey PRIMARY KEY (_key);


--
-- Name: legacy_object legacy_object__key_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_object
    ADD CONSTRAINT legacy_object__key_type_key UNIQUE (_key, type);


--
-- Name: legacy_object legacy_object_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_object
    ADD CONSTRAINT legacy_object_pkey PRIMARY KEY (_key);


--
-- Name: legacy_set legacy_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_set
    ADD CONSTRAINT legacy_set_pkey PRIMARY KEY (_key, member);


--
-- Name: legacy_string legacy_string_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_string
    ADD CONSTRAINT legacy_string_pkey PRIMARY KEY (_key);


--
-- Name: legacy_zset legacy_zset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_zset
    ADD CONSTRAINT legacy_zset_pkey PRIMARY KEY (_key, value);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);


--
-- Name: idx__legacy_object__expireAt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx__legacy_object__expireAt" ON public.legacy_object USING btree ("expireAt");


--
-- Name: idx__legacy_zset__key__score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx__legacy_zset__key__score ON public.legacy_zset USING btree (_key, score DESC);


--
-- Name: session_expire_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_expire_idx ON public.session USING btree (expire);

ALTER TABLE public.session CLUSTER ON session_expire_idx;


--
-- Name: legacy_hash fk__legacy_hash__key; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_hash
    ADD CONSTRAINT fk__legacy_hash__key FOREIGN KEY (_key, type) REFERENCES public.legacy_object(_key, type) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: legacy_list fk__legacy_list__key; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_list
    ADD CONSTRAINT fk__legacy_list__key FOREIGN KEY (_key, type) REFERENCES public.legacy_object(_key, type) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: legacy_set fk__legacy_set__key; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_set
    ADD CONSTRAINT fk__legacy_set__key FOREIGN KEY (_key, type) REFERENCES public.legacy_object(_key, type) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: legacy_string fk__legacy_string__key; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_string
    ADD CONSTRAINT fk__legacy_string__key FOREIGN KEY (_key, type) REFERENCES public.legacy_object(_key, type) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: legacy_zset fk__legacy_zset__key; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_zset
    ADD CONSTRAINT fk__legacy_zset__key FOREIGN KEY (_key, type) REFERENCES public.legacy_object(_key, type) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


