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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: CredentialType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CredentialType" AS ENUM (
    'OAUTH'
);


--
-- Name: LicenseStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."LicenseStatus" AS ENUM (
    'ACTIVE',
    'REVOKED'
);


--
-- Name: LicenseType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."LicenseType" AS ENUM (
    'PLUS',
    'ORGANIZATION',
    'ENTERPRISE'
);


--
-- Name: SpaceMemberRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SpaceMemberRole" AS ENUM (
    'ADMIN',
    'MEMBER'
);


--
-- Name: participant_visibility; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.participant_visibility AS ENUM (
    'full',
    'scoresOnly',
    'limited'
);


--
-- Name: poll_closed_reason; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.poll_closed_reason AS ENUM (
    'auto',
    'manual'
);


--
-- Name: poll_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.poll_kind AS ENUM (
    'date',
    'time'
);


--
-- Name: poll_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.poll_status AS ENUM (
    'open',
    'closed',
    'scheduled',
    'canceled'
);


--
-- Name: scheduled_event_invite_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.scheduled_event_invite_status AS ENUM (
    'pending',
    'accepted',
    'declined',
    'tentative'
);


--
-- Name: scheduled_event_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.scheduled_event_status AS ENUM (
    'confirmed',
    'canceled',
    'unconfirmed'
);


--
-- Name: space_tiers; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.space_tiers AS ENUM (
    'hobby',
    'pro'
);


--
-- Name: subscription_interval; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscription_interval AS ENUM (
    'month',
    'year'
);


--
-- Name: subscription_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscription_status AS ENUM (
    'incomplete',
    'incomplete_expired',
    'active',
    'paused',
    'trialing',
    'past_due',
    'canceled',
    'unpaid'
);


--
-- Name: time_format; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.time_format AS ENUM (
    'hours12',
    'hours24'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'user'
);


--
-- Name: vote_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.vote_type AS ENUM (
    'yes',
    'no',
    'ifNeedBe'
);


--
-- Name: nanoid(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.nanoid(size integer DEFAULT 21) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  id text := '';
  i int := 0;
  urlAlphabet char(64) := 'ModuleSymbhasOwnPr-0123456789ABCDEFGHNRVfgctiUvz_KqYTJkLxpZXIjQW';
  bytes bytea := gen_random_bytes(size);
  byte int;
  pos int;
BEGIN
  WHILE i < size LOOP
    byte := get_byte(bytes, i);
    pos := (byte & 63) + 1; -- + 1 because substr starts at 1 for some reason
    id := id || substr(urlAlphabet, pos, 1);
    i = i + 1;
  END LOOP;
  RETURN id;
END
$$;


--
-- Name: prevent_delete_instance_settings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.prevent_delete_instance_settings() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.id = 1 THEN
    RAISE EXCEPTION 'Deleting the instance_settings record (id=1) is not permitted.';
  END IF;
  RETURN OLD;
END;
$$;


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
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id text NOT NULL,
    user_id text NOT NULL,
    provider text NOT NULL,
    provider_account_id text NOT NULL,
    refresh_token text,
    access_token text,
    expires_at integer,
    scope text,
    id_token text,
    access_token_expires_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    password text,
    refresh_token_expires_at timestamp(3) without time zone,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: calendar_connections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calendar_connections (
    id text NOT NULL,
    user_id text NOT NULL,
    provider text NOT NULL,
    integration_id text NOT NULL,
    provider_account_id text NOT NULL,
    email text NOT NULL,
    display_name text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    credential_id text NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id text NOT NULL,
    content text NOT NULL,
    poll_id text NOT NULL,
    author_name text NOT NULL,
    user_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone
);


--
-- Name: credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credentials (
    id text NOT NULL,
    user_id text NOT NULL,
    provider text NOT NULL,
    provider_account_id text NOT NULL,
    type public."CredentialType" NOT NULL,
    secret text NOT NULL,
    scopes text[],
    expires_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: event_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_types (
    id text NOT NULL,
    space_id text NOT NULL,
    host_id text NOT NULL,
    name text NOT NULL,
    duration_minutes integer NOT NULL,
    capacity integer,
    description text,
    location jsonb,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp(3) without time zone
);


--
-- Name: instance_licenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instance_licenses (
    id text NOT NULL,
    license_key text NOT NULL,
    version integer,
    type public."LicenseType" NOT NULL,
    seats integer,
    issued_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp(3) without time zone,
    licensee_email text,
    licensee_name text,
    status public."LicenseStatus" DEFAULT 'ACTIVE'::public."LicenseStatus" NOT NULL,
    white_label_addon boolean DEFAULT false NOT NULL
);


--
-- Name: instance_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instance_settings (
    id integer DEFAULT 1 NOT NULL,
    disable_user_registration boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    instance_id uuid DEFAULT gen_random_uuid() NOT NULL,
    CONSTRAINT instance_settings_singleton CHECK ((id = 1))
);


--
-- Name: license_validations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.license_validations (
    id text NOT NULL,
    license_id text NOT NULL,
    ip_address text,
    fingerprint text,
    validated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_agent text
);


--
-- Name: licenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.licenses (
    id text NOT NULL,
    license_key text NOT NULL,
    version integer,
    type public."LicenseType" NOT NULL,
    seats integer,
    issued_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp(3) without time zone,
    licensee_email text,
    licensee_name text,
    status public."LicenseStatus" DEFAULT 'ACTIVE'::public."LicenseStatus" NOT NULL,
    white_label_addon boolean DEFAULT false NOT NULL,
    idempotency_key text
);


--
-- Name: options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.options (
    id text NOT NULL,
    poll_id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    duration_minutes integer DEFAULT 0 NOT NULL,
    start_time timestamp(0) without time zone NOT NULL
);


--
-- Name: participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.participants (
    id text NOT NULL,
    name text NOT NULL,
    user_id text,
    poll_id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone,
    email text,
    deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp(3) without time zone,
    locale text,
    time_zone text,
    note text
);


--
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_methods (
    id text NOT NULL,
    user_id text NOT NULL,
    type text NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: polls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.polls (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    deadline timestamp(3) without time zone,
    title text NOT NULL,
    description text,
    location text,
    user_id text,
    time_zone text,
    deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp(3) without time zone,
    event_id text,
    hide_participants boolean DEFAULT false NOT NULL,
    disable_comments boolean DEFAULT true NOT NULL,
    hide_scores boolean DEFAULT false NOT NULL,
    require_participant_email boolean DEFAULT false NOT NULL,
    status public.poll_status DEFAULT 'open'::public.poll_status NOT NULL,
    scheduled_event_id text,
    space_id text,
    muted boolean DEFAULT false NOT NULL,
    kind public.poll_kind DEFAULT 'date'::public.poll_kind NOT NULL,
    closed_reason public.poll_closed_reason
);


--
-- Name: provider_calendars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provider_calendars (
    id text NOT NULL,
    calendar_connection_id text NOT NULL,
    provider_calendar_id text NOT NULL,
    name text NOT NULL,
    "primary" boolean DEFAULT false NOT NULL,
    time_zone text,
    selected boolean DEFAULT false NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    writable boolean DEFAULT false NOT NULL,
    provider_data jsonb,
    last_synced_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: registered_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registered_instances (
    id text NOT NULL,
    instance_id text NOT NULL,
    version text NOT NULL,
    first_seen_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_seen_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: rescheduled_event_dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rescheduled_event_dates (
    id text NOT NULL,
    scheduled_event_id text NOT NULL,
    start timestamp(3) without time zone NOT NULL,
    "end" timestamp(3) without time zone NOT NULL,
    all_day boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: scheduled_event_invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduled_event_invites (
    id text NOT NULL,
    scheduled_event_id text NOT NULL,
    invitee_name text NOT NULL,
    invitee_email public.citext NOT NULL,
    invitee_id text,
    invitee_time_zone text,
    status public.scheduled_event_invite_status DEFAULT 'pending'::public.scheduled_event_invite_status NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    invitee_locale text,
    uid text NOT NULL
);


--
-- Name: scheduled_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduled_events (
    id text NOT NULL,
    user_id text NOT NULL,
    title text NOT NULL,
    description text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    status public.scheduled_event_status DEFAULT 'confirmed'::public.scheduled_event_status NOT NULL,
    time_zone text,
    start timestamp(3) without time zone NOT NULL,
    "end" timestamp(3) without time zone NOT NULL,
    all_day boolean DEFAULT false NOT NULL,
    deleted_at timestamp(3) without time zone,
    space_id text NOT NULL,
    sequence integer DEFAULT 0 NOT NULL,
    uid text NOT NULL,
    capacity integer,
    event_type_id text,
    sheet_slot_id text,
    hide_attendees boolean DEFAULT false NOT NULL,
    location jsonb,
    conferencing jsonb,
    CONSTRAINT all_day_is_floating CHECK (((NOT all_day) OR (time_zone IS NULL))),
    CONSTRAINT all_day_is_utc_midnight CHECK (((NOT all_day) OR ((date_trunc('day'::text, start) = start) AND (date_trunc('day'::text, "end") = "end") AND ("end" > start))))
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id text NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL,
    token text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    ip_address text,
    user_agent text,
    user_id text NOT NULL,
    impersonated_by text
);


--
-- Name: sheet_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sheet_slots (
    id text NOT NULL,
    sheet_id text NOT NULL,
    event_type_id text NOT NULL,
    start_time timestamp(3) without time zone NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: sheets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sheets (
    id text NOT NULL,
    space_id text NOT NULL,
    host_id text NOT NULL,
    title text NOT NULL,
    description text,
    url_id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp(3) without time zone
);


--
-- Name: space_api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.space_api_keys (
    id text NOT NULL,
    space_id text NOT NULL,
    name text NOT NULL,
    prefix text NOT NULL,
    hashed_key text NOT NULL,
    last_used_at timestamp(3) without time zone,
    expires_at timestamp(3) without time zone,
    revoked_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: space_member_invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.space_member_invites (
    id text NOT NULL,
    space_id text NOT NULL,
    email text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    role public."SpaceMemberRole" DEFAULT 'MEMBER'::public."SpaceMemberRole" NOT NULL,
    inviter_id text NOT NULL
);


--
-- Name: space_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.space_members (
    id text NOT NULL,
    space_id text NOT NULL,
    user_id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    role public."SpaceMemberRole" DEFAULT 'MEMBER'::public."SpaceMemberRole" NOT NULL,
    last_selected_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: spaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spaces (
    id text NOT NULL,
    name text NOT NULL,
    owner_id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    image text,
    tier public.space_tiers DEFAULT 'hobby'::public.space_tiers NOT NULL,
    primary_color text,
    show_branding boolean DEFAULT false NOT NULL
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id text NOT NULL,
    price_id text NOT NULL,
    active boolean NOT NULL,
    currency text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    period_start timestamp(3) without time zone NOT NULL,
    period_end timestamp(3) without time zone NOT NULL,
    amount integer NOT NULL,
    cancel_at_period_end boolean DEFAULT false NOT NULL,
    "interval" public.subscription_interval NOT NULL,
    status public.subscription_status NOT NULL,
    user_id text NOT NULL,
    space_id text NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    subscription_item_id text NOT NULL,
    discount_amount_off integer,
    discount_percent_off double precision
);


--
-- Name: user_notification_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_notification_preferences (
    id text NOT NULL,
    user_id text NOT NULL,
    prefs jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id text NOT NULL,
    name text NOT NULL,
    email public.citext NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone,
    customer_id text,
    locale text,
    time_format public.time_format,
    time_zone text,
    week_start integer,
    image text,
    ban_reason text,
    banned boolean DEFAULT false NOT NULL,
    banned_at timestamp(3) without time zone,
    role public.user_role DEFAULT 'user'::public.user_role NOT NULL,
    default_destination_calendar_id text,
    email_verified boolean,
    ban_expires timestamp(3) without time zone,
    last_login_method text,
    anonymous boolean DEFAULT false NOT NULL,
    last_seen_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp(3) without time zone
);


--
-- Name: verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.verifications (
    id text NOT NULL,
    identifier text NOT NULL,
    value text NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
    id text NOT NULL,
    participant_id text NOT NULL,
    option_id text NOT NULL,
    poll_id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone,
    type public.vote_type DEFAULT 'yes'::public.vote_type NOT NULL
);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: calendar_connections calendar_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_connections
    ADD CONSTRAINT calendar_connections_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: credentials credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credentials
    ADD CONSTRAINT credentials_pkey PRIMARY KEY (id);


--
-- Name: event_types event_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT event_types_pkey PRIMARY KEY (id);


--
-- Name: instance_licenses instance_licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance_licenses
    ADD CONSTRAINT instance_licenses_pkey PRIMARY KEY (id);


--
-- Name: instance_settings instance_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance_settings
    ADD CONSTRAINT instance_settings_pkey PRIMARY KEY (id);


--
-- Name: license_validations license_validations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.license_validations
    ADD CONSTRAINT license_validations_pkey PRIMARY KEY (id);


--
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- Name: options options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: participants participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_pkey PRIMARY KEY (id);


--
-- Name: payment_methods payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);


--
-- Name: polls polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_pkey PRIMARY KEY (id);


--
-- Name: provider_calendars provider_calendars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_calendars
    ADD CONSTRAINT provider_calendars_pkey PRIMARY KEY (id);


--
-- Name: registered_instances registered_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registered_instances
    ADD CONSTRAINT registered_instances_pkey PRIMARY KEY (id);


--
-- Name: rescheduled_event_dates rescheduled_event_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rescheduled_event_dates
    ADD CONSTRAINT rescheduled_event_dates_pkey PRIMARY KEY (id);


--
-- Name: scheduled_event_invites scheduled_event_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_event_invites
    ADD CONSTRAINT scheduled_event_invites_pkey PRIMARY KEY (id);


--
-- Name: scheduled_events scheduled_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_events
    ADD CONSTRAINT scheduled_events_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sheet_slots sheet_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sheet_slots
    ADD CONSTRAINT sheet_slots_pkey PRIMARY KEY (id);


--
-- Name: sheets sheets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sheets
    ADD CONSTRAINT sheets_pkey PRIMARY KEY (id);


--
-- Name: space_api_keys space_api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_api_keys
    ADD CONSTRAINT space_api_keys_pkey PRIMARY KEY (id);


--
-- Name: space_member_invites space_member_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_member_invites
    ADD CONSTRAINT space_member_invites_pkey PRIMARY KEY (id);


--
-- Name: space_members space_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT space_members_pkey PRIMARY KEY (id);


--
-- Name: spaces spaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT spaces_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: user_notification_preferences user_notification_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notification_preferences
    ADD CONSTRAINT user_notification_preferences_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: verifications verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verifications
    ADD CONSTRAINT verifications_pkey PRIMARY KEY (id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public.users USING btree (email);


--
-- Name: accounts_provider_provider_account_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX accounts_provider_provider_account_id_key ON public.accounts USING btree (provider, provider_account_id);


--
-- Name: accounts_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_user_id_idx ON public.accounts USING btree (user_id);


--
-- Name: calendar_connections_user_id_provider_provider_account_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX calendar_connections_user_id_provider_provider_account_id_key ON public.calendar_connections USING btree (user_id, provider, provider_account_id);


--
-- Name: comments_poll_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_poll_id_idx ON public.comments USING btree (poll_id);


--
-- Name: comments_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_user_id_idx ON public.comments USING btree (user_id);


--
-- Name: connection_selected_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX connection_selected_idx ON public.provider_calendars USING btree (calendar_connection_id, selected);


--
-- Name: credential_expiry_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX credential_expiry_idx ON public.credentials USING btree (expires_at);


--
-- Name: credentials_user_id_provider_provider_account_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX credentials_user_id_provider_provider_account_id_key ON public.credentials USING btree (user_id, provider, provider_account_id);


--
-- Name: event_types_host_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_types_host_id_idx ON public.event_types USING btree (host_id);


--
-- Name: event_types_space_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_types_space_id_idx ON public.event_types USING btree (space_id);


--
-- Name: instance_licenses_license_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX instance_licenses_license_key_key ON public.instance_licenses USING btree (license_key);


--
-- Name: instance_settings_instance_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX instance_settings_instance_id_key ON public.instance_settings USING btree (instance_id);


--
-- Name: licenses_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX licenses_idempotency_key_key ON public.licenses USING btree (idempotency_key);


--
-- Name: licenses_license_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX licenses_license_key_key ON public.licenses USING btree (license_key);


--
-- Name: options_poll_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX options_poll_id_idx ON public.options USING hash (poll_id);


--
-- Name: participants_poll_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX participants_poll_id_idx ON public.participants USING hash (poll_id);


--
-- Name: participants_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX participants_user_id_idx ON public.participants USING btree (user_id);


--
-- Name: polls_event_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX polls_event_id_key ON public.polls USING btree (event_id);


--
-- Name: polls_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX polls_id_key ON public.polls USING btree (id);


--
-- Name: polls_space_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX polls_space_id_idx ON public.polls USING btree (space_id);


--
-- Name: polls_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX polls_user_id_idx ON public.polls USING btree (user_id);


--
-- Name: primary_calendar_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX primary_calendar_idx ON public.provider_calendars USING btree ("primary");


--
-- Name: provider_calendars_calendar_connection_id_provider_calendar_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX provider_calendars_calendar_connection_id_provider_calendar_key ON public.provider_calendars USING btree (calendar_connection_id, provider_calendar_id);


--
-- Name: registered_instances_instance_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX registered_instances_instance_id_key ON public.registered_instances USING btree (instance_id);


--
-- Name: rescheduled_event_dates_scheduled_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rescheduled_event_dates_scheduled_event_id_idx ON public.rescheduled_event_dates USING btree (scheduled_event_id);


--
-- Name: scheduled_event_invites_invitee_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_event_invites_invitee_email_idx ON public.scheduled_event_invites USING btree (invitee_email);


--
-- Name: scheduled_event_invites_invitee_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_event_invites_invitee_id_idx ON public.scheduled_event_invites USING btree (invitee_id);


--
-- Name: scheduled_event_invites_scheduled_event_id_invitee_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX scheduled_event_invites_scheduled_event_id_invitee_email_key ON public.scheduled_event_invites USING btree (scheduled_event_id, invitee_email);


--
-- Name: scheduled_event_invites_uid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX scheduled_event_invites_uid_key ON public.scheduled_event_invites USING btree (uid);


--
-- Name: scheduled_events_event_type_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_events_event_type_id_idx ON public.scheduled_events USING btree (event_type_id);


--
-- Name: scheduled_events_sheet_slot_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX scheduled_events_sheet_slot_id_key ON public.scheduled_events USING btree (sheet_slot_id);


--
-- Name: scheduled_events_space_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_events_space_id_idx ON public.scheduled_events USING btree (space_id);


--
-- Name: scheduled_events_space_id_status_start_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_events_space_id_status_start_idx ON public.scheduled_events USING btree (space_id, status, start);


--
-- Name: scheduled_events_uid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX scheduled_events_uid_key ON public.scheduled_events USING btree (uid);


--
-- Name: scheduled_events_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_events_user_id_idx ON public.scheduled_events USING btree (user_id);


--
-- Name: sessions_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sessions_token_key ON public.sessions USING btree (token);


--
-- Name: sheet_slots_event_type_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sheet_slots_event_type_id_idx ON public.sheet_slots USING btree (event_type_id);


--
-- Name: sheet_slots_sheet_id_start_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sheet_slots_sheet_id_start_time_idx ON public.sheet_slots USING btree (sheet_id, start_time);


--
-- Name: sheets_host_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sheets_host_id_idx ON public.sheets USING btree (host_id);


--
-- Name: sheets_space_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sheets_space_id_idx ON public.sheets USING btree (space_id);


--
-- Name: sheets_url_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sheets_url_id_key ON public.sheets USING btree (url_id);


--
-- Name: space_api_key_expires_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX space_api_key_expires_idx ON public.space_api_keys USING btree (expires_at);


--
-- Name: space_api_key_revoked_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX space_api_key_revoked_idx ON public.space_api_keys USING btree (revoked_at);


--
-- Name: space_api_key_space_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX space_api_key_space_idx ON public.space_api_keys USING btree (space_id);


--
-- Name: space_api_keys_prefix_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX space_api_keys_prefix_key ON public.space_api_keys USING btree (prefix);


--
-- Name: space_member_invites_space_id_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX space_member_invites_space_id_email_key ON public.space_member_invites USING btree (space_id, email);


--
-- Name: space_members_space_id_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX space_members_space_id_user_id_key ON public.space_members USING btree (space_id, user_id);


--
-- Name: space_members_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX space_members_user_id_idx ON public.space_members USING btree (user_id);


--
-- Name: spaces_owner_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX spaces_owner_id_idx ON public.spaces USING btree (owner_id);


--
-- Name: subscriptions_space_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscriptions_space_id_idx ON public.subscriptions USING btree (space_id);


--
-- Name: subscriptions_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscriptions_user_id_idx ON public.subscriptions USING btree (user_id);


--
-- Name: sync_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_time_idx ON public.provider_calendars USING btree (last_synced_at);


--
-- Name: user_notification_preferences_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_notification_preferences_user_id_key ON public.user_notification_preferences USING btree (user_id);


--
-- Name: users_anonymous_last_seen_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_anonymous_last_seen_at_idx ON public.users USING btree (anonymous, last_seen_at);


--
-- Name: users_deleted_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_deleted_at_idx ON public.users USING btree (deleted_at);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: verifications_identifier_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX verifications_identifier_idx ON public.verifications USING btree (identifier);


--
-- Name: verifications_identifier_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX verifications_identifier_key ON public.verifications USING btree (identifier);


--
-- Name: votes_option_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX votes_option_id_idx ON public.votes USING hash (option_id);


--
-- Name: votes_participant_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX votes_participant_id_idx ON public.votes USING hash (participant_id);


--
-- Name: votes_poll_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX votes_poll_id_idx ON public.votes USING hash (poll_id);


--
-- Name: instance_settings trg_prevent_instance_settings_deletion; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_prevent_instance_settings_deletion BEFORE DELETE ON public.instance_settings FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_instance_settings();


--
-- Name: accounts accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: calendar_connections calendar_connections_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_connections
    ADD CONSTRAINT calendar_connections_credential_id_fkey FOREIGN KEY (credential_id) REFERENCES public.credentials(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: calendar_connections calendar_connections_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_connections
    ADD CONSTRAINT calendar_connections_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comments comments_poll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_poll_id_fkey FOREIGN KEY (poll_id) REFERENCES public.polls(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: credentials credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credentials
    ADD CONSTRAINT credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: event_types event_types_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT event_types_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: event_types event_types_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT event_types_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: license_validations license_validations_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.license_validations
    ADD CONSTRAINT license_validations_license_id_fkey FOREIGN KEY (license_id) REFERENCES public.licenses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: options options_poll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT options_poll_id_fkey FOREIGN KEY (poll_id) REFERENCES public.polls(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: participants participants_poll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_poll_id_fkey FOREIGN KEY (poll_id) REFERENCES public.polls(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: participants participants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: payment_methods payment_methods_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: polls polls_scheduled_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_scheduled_event_id_fkey FOREIGN KEY (scheduled_event_id) REFERENCES public.scheduled_events(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: polls polls_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: polls polls_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: provider_calendars provider_calendars_calendar_connection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_calendars
    ADD CONSTRAINT provider_calendars_calendar_connection_id_fkey FOREIGN KEY (calendar_connection_id) REFERENCES public.calendar_connections(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rescheduled_event_dates rescheduled_event_dates_scheduled_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rescheduled_event_dates
    ADD CONSTRAINT rescheduled_event_dates_scheduled_event_id_fkey FOREIGN KEY (scheduled_event_id) REFERENCES public.scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: scheduled_event_invites scheduled_event_invites_invitee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_event_invites
    ADD CONSTRAINT scheduled_event_invites_invitee_id_fkey FOREIGN KEY (invitee_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: scheduled_event_invites scheduled_event_invites_scheduled_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_event_invites
    ADD CONSTRAINT scheduled_event_invites_scheduled_event_id_fkey FOREIGN KEY (scheduled_event_id) REFERENCES public.scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: scheduled_events scheduled_events_event_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_events
    ADD CONSTRAINT scheduled_events_event_type_id_fkey FOREIGN KEY (event_type_id) REFERENCES public.event_types(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: scheduled_events scheduled_events_sheet_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_events
    ADD CONSTRAINT scheduled_events_sheet_slot_id_fkey FOREIGN KEY (sheet_slot_id) REFERENCES public.sheet_slots(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: scheduled_events scheduled_events_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_events
    ADD CONSTRAINT scheduled_events_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: scheduled_events scheduled_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_events
    ADD CONSTRAINT scheduled_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sessions sessions_impersonated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_impersonated_by_fkey FOREIGN KEY (impersonated_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sheet_slots sheet_slots_event_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sheet_slots
    ADD CONSTRAINT sheet_slots_event_type_id_fkey FOREIGN KEY (event_type_id) REFERENCES public.event_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sheet_slots sheet_slots_sheet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sheet_slots
    ADD CONSTRAINT sheet_slots_sheet_id_fkey FOREIGN KEY (sheet_id) REFERENCES public.sheets(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sheets sheets_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sheets
    ADD CONSTRAINT sheets_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sheets sheets_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sheets
    ADD CONSTRAINT sheets_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: space_api_keys space_api_keys_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_api_keys
    ADD CONSTRAINT space_api_keys_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: space_member_invites space_member_invites_inviter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_member_invites
    ADD CONSTRAINT space_member_invites_inviter_id_fkey FOREIGN KEY (inviter_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: space_member_invites space_member_invites_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_member_invites
    ADD CONSTRAINT space_member_invites_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: space_members space_members_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT space_members_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: space_members space_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_members
    ADD CONSTRAINT space_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spaces spaces_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT spaces_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_space_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_space_id_fkey FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_notification_preferences user_notification_preferences_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notification_preferences
    ADD CONSTRAINT user_notification_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_default_destination_calendar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_default_destination_calendar_id_fkey FOREIGN KEY (default_destination_calendar_id) REFERENCES public.provider_calendars(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: votes votes_option_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_option_id_fkey FOREIGN KEY (option_id) REFERENCES public.options(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: votes votes_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: votes votes_poll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_poll_id_fkey FOREIGN KEY (poll_id) REFERENCES public.polls(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


