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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: __diesel_schema_migrations; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.__diesel_schema_migrations (
    version character varying(50) NOT NULL,
    run_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);



--
-- Name: archives; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.archives (
    user_uuid character(36) NOT NULL,
    cipher_uuid character(36) NOT NULL,
    archived_at timestamp without time zone DEFAULT now() NOT NULL
);



--
-- Name: attachments; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.attachments (
    id text NOT NULL,
    cipher_uuid character varying(40) NOT NULL,
    file_name text NOT NULL,
    file_size bigint NOT NULL,
    akey text
);



--
-- Name: auth_requests; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.auth_requests (
    uuid character(36) NOT NULL,
    user_uuid character(36) NOT NULL,
    organization_uuid character(36),
    request_device_identifier character(36) NOT NULL,
    device_type integer NOT NULL,
    request_ip text NOT NULL,
    response_device_id character(36),
    access_code text NOT NULL,
    public_key text NOT NULL,
    enc_key text,
    master_password_hash text,
    approved boolean,
    creation_date timestamp without time zone NOT NULL,
    response_date timestamp without time zone,
    authentication_date timestamp without time zone
);



--
-- Name: ciphers; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.ciphers (
    uuid character varying(40) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_uuid character varying(40),
    organization_uuid character varying(40),
    atype integer NOT NULL,
    name text NOT NULL,
    notes text,
    fields text,
    data text NOT NULL,
    password_history text,
    deleted_at timestamp without time zone,
    reprompt integer,
    key text
);



--
-- Name: ciphers_collections; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.ciphers_collections (
    cipher_uuid character varying(40) NOT NULL,
    collection_uuid character varying(40) NOT NULL
);



--
-- Name: collections; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.collections (
    uuid character varying(40) NOT NULL,
    org_uuid character varying(40) NOT NULL,
    name text NOT NULL,
    external_id text
);



--
-- Name: collections_groups; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.collections_groups (
    collections_uuid character varying(40) NOT NULL,
    groups_uuid character(36) NOT NULL,
    read_only boolean NOT NULL,
    hide_passwords boolean NOT NULL,
    manage boolean DEFAULT false NOT NULL
);



--
-- Name: devices; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.devices (
    uuid character varying(40) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_uuid character varying(40) NOT NULL,
    name text NOT NULL,
    atype integer NOT NULL,
    push_token text,
    refresh_token text NOT NULL,
    twofactor_remember text,
    push_uuid text
);



--
-- Name: emergency_access; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.emergency_access (
    uuid character(36) NOT NULL,
    grantor_uuid character(36),
    grantee_uuid character(36),
    email character varying(255),
    key_encrypted text,
    atype integer NOT NULL,
    status integer NOT NULL,
    wait_time_days integer NOT NULL,
    recovery_initiated_at timestamp without time zone,
    last_notification_at timestamp without time zone,
    updated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL
);



--
-- Name: event; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.event (
    uuid character(36) NOT NULL,
    event_type integer NOT NULL,
    user_uuid character(36),
    org_uuid character(36),
    cipher_uuid character(36),
    collection_uuid character(36),
    group_uuid character(36),
    org_user_uuid character(36),
    act_user_uuid character(36),
    device_type integer,
    ip_address text,
    event_date timestamp without time zone NOT NULL,
    policy_uuid character(36),
    provider_uuid character(36),
    provider_user_uuid character(36),
    provider_org_uuid character(36)
);



--
-- Name: favorites; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.favorites (
    user_uuid character varying(40) NOT NULL,
    cipher_uuid character varying(40) NOT NULL
);



--
-- Name: folders; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.folders (
    uuid character varying(40) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_uuid character varying(40) NOT NULL,
    name text NOT NULL
);



--
-- Name: folders_ciphers; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.folders_ciphers (
    cipher_uuid character varying(40) NOT NULL,
    folder_uuid character varying(40) NOT NULL
);



--
-- Name: groups; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.groups (
    uuid character(36) NOT NULL,
    organizations_uuid character varying(40) NOT NULL,
    name character varying(100) NOT NULL,
    access_all boolean NOT NULL,
    external_id character varying(300),
    creation_date timestamp without time zone NOT NULL,
    revision_date timestamp without time zone NOT NULL
);



--
-- Name: groups_users; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.groups_users (
    groups_uuid character(36) NOT NULL,
    users_organizations_uuid character varying(36) NOT NULL
);



--
-- Name: invitations; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.invitations (
    email text NOT NULL
);



--
-- Name: org_policies; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.org_policies (
    uuid character(36) NOT NULL,
    org_uuid character(36) NOT NULL,
    atype integer NOT NULL,
    enabled boolean NOT NULL,
    data text NOT NULL
);



--
-- Name: organization_api_key; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.organization_api_key (
    uuid character(36) NOT NULL,
    org_uuid character(36) NOT NULL,
    atype integer NOT NULL,
    api_key character varying(255),
    revision_date timestamp without time zone NOT NULL
);



--
-- Name: organizations; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.organizations (
    uuid character varying(40) NOT NULL,
    name text NOT NULL,
    billing_email text NOT NULL,
    private_key text,
    public_key text
);



--
-- Name: sends; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.sends (
    uuid character(36) NOT NULL,
    user_uuid character(36),
    organization_uuid character(36),
    name text NOT NULL,
    notes text,
    atype integer NOT NULL,
    data text NOT NULL,
    akey text NOT NULL,
    password_hash bytea,
    password_salt bytea,
    password_iter integer,
    max_access_count integer,
    access_count integer NOT NULL,
    creation_date timestamp without time zone NOT NULL,
    revision_date timestamp without time zone NOT NULL,
    expiration_date timestamp without time zone,
    deletion_date timestamp without time zone NOT NULL,
    disabled boolean NOT NULL,
    hide_email boolean
);



--
-- Name: sso_auth; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.sso_auth (
    state text NOT NULL,
    client_challenge text NOT NULL,
    nonce text NOT NULL,
    redirect_uri text NOT NULL,
    code_response text,
    auth_response text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    binding_hash text,
    code_response_error text
);



--
-- Name: sso_users; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.sso_users (
    user_uuid character(36) NOT NULL,
    identifier text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);



--
-- Name: twofactor; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.twofactor (
    uuid character varying(40) NOT NULL,
    user_uuid character varying(40) NOT NULL,
    atype integer NOT NULL,
    enabled boolean NOT NULL,
    data text NOT NULL,
    last_used bigint DEFAULT 0 NOT NULL
);



--
-- Name: twofactor_duo_ctx; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.twofactor_duo_ctx (
    state character varying(64) NOT NULL,
    user_email character varying(255) NOT NULL,
    nonce character varying(64) NOT NULL,
    exp bigint NOT NULL
);



--
-- Name: twofactor_incomplete; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.twofactor_incomplete (
    user_uuid character varying(40) NOT NULL,
    device_uuid character varying(40) NOT NULL,
    device_name text NOT NULL,
    login_time timestamp without time zone NOT NULL,
    ip_address text NOT NULL,
    device_type integer DEFAULT 14 NOT NULL
);



--
-- Name: users; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.users (
    uuid character varying(40) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email text NOT NULL,
    name text NOT NULL,
    password_hash bytea NOT NULL,
    salt bytea NOT NULL,
    password_iterations integer NOT NULL,
    password_hint text,
    akey text NOT NULL,
    private_key text,
    public_key text,
    totp_secret text,
    totp_recover text,
    security_stamp text NOT NULL,
    equivalent_domains text NOT NULL,
    excluded_globals text NOT NULL,
    client_kdf_type integer DEFAULT 0 NOT NULL,
    client_kdf_iter integer DEFAULT 100000 NOT NULL,
    verified_at timestamp without time zone,
    last_verifying_at timestamp without time zone,
    login_verify_count integer DEFAULT 0 NOT NULL,
    email_new character varying(255) DEFAULT NULL::character varying,
    email_new_token character varying(16) DEFAULT NULL::character varying,
    enabled boolean DEFAULT true NOT NULL,
    stamp_exception text,
    api_key text,
    avatar_color text,
    client_kdf_memory integer,
    client_kdf_parallelism integer,
    external_id text
);



--
-- Name: users_collections; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.users_collections (
    user_uuid character varying(40) NOT NULL,
    collection_uuid character varying(40) NOT NULL,
    read_only boolean DEFAULT false NOT NULL,
    hide_passwords boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL
);



--
-- Name: users_organizations; Type: TABLE; Schema: public; Owner: vaultwarden
--

CREATE TABLE public.users_organizations (
    uuid character varying(40) NOT NULL,
    user_uuid character varying(40) NOT NULL,
    org_uuid character varying(40) NOT NULL,
    access_all boolean NOT NULL,
    akey text NOT NULL,
    status integer NOT NULL,
    atype integer NOT NULL,
    reset_password_key text,
    external_id text,
    invited_by_email text
);



--
-- Name: __diesel_schema_migrations __diesel_schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.__diesel_schema_migrations
    ADD CONSTRAINT __diesel_schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: archives archives_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.archives
    ADD CONSTRAINT archives_pkey PRIMARY KEY (user_uuid, cipher_uuid);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: auth_requests auth_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.auth_requests
    ADD CONSTRAINT auth_requests_pkey PRIMARY KEY (uuid);


--
-- Name: ciphers_collections ciphers_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.ciphers_collections
    ADD CONSTRAINT ciphers_collections_pkey PRIMARY KEY (cipher_uuid, collection_uuid);


--
-- Name: ciphers ciphers_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.ciphers
    ADD CONSTRAINT ciphers_pkey PRIMARY KEY (uuid);


--
-- Name: collections_groups collections_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.collections_groups
    ADD CONSTRAINT collections_groups_pkey PRIMARY KEY (collections_uuid, groups_uuid);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (uuid);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (uuid, user_uuid);


--
-- Name: emergency_access emergency_access_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.emergency_access
    ADD CONSTRAINT emergency_access_pkey PRIMARY KEY (uuid);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (uuid);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (user_uuid, cipher_uuid);


--
-- Name: folders_ciphers folders_ciphers_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.folders_ciphers
    ADD CONSTRAINT folders_ciphers_pkey PRIMARY KEY (cipher_uuid, folder_uuid);


--
-- Name: folders folders_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_pkey PRIMARY KEY (uuid);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (uuid);


--
-- Name: groups_users groups_users_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.groups_users
    ADD CONSTRAINT groups_users_pkey PRIMARY KEY (groups_uuid, users_organizations_uuid);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (email);


--
-- Name: org_policies org_policies_org_uuid_atype_key; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.org_policies
    ADD CONSTRAINT org_policies_org_uuid_atype_key UNIQUE (org_uuid, atype);


--
-- Name: org_policies org_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.org_policies
    ADD CONSTRAINT org_policies_pkey PRIMARY KEY (uuid);


--
-- Name: organization_api_key organization_api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.organization_api_key
    ADD CONSTRAINT organization_api_key_pkey PRIMARY KEY (uuid, org_uuid);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (uuid);


--
-- Name: sends sends_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.sends
    ADD CONSTRAINT sends_pkey PRIMARY KEY (uuid);


--
-- Name: sso_auth sso_auth_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.sso_auth
    ADD CONSTRAINT sso_auth_pkey PRIMARY KEY (state);


--
-- Name: sso_users sso_users_identifier_key; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.sso_users
    ADD CONSTRAINT sso_users_identifier_key UNIQUE (identifier);


--
-- Name: sso_users sso_users_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.sso_users
    ADD CONSTRAINT sso_users_pkey PRIMARY KEY (user_uuid);


--
-- Name: twofactor_duo_ctx twofactor_duo_ctx_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.twofactor_duo_ctx
    ADD CONSTRAINT twofactor_duo_ctx_pkey PRIMARY KEY (state);


--
-- Name: twofactor_incomplete twofactor_incomplete_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.twofactor_incomplete
    ADD CONSTRAINT twofactor_incomplete_pkey PRIMARY KEY (user_uuid, device_uuid);


--
-- Name: twofactor twofactor_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.twofactor
    ADD CONSTRAINT twofactor_pkey PRIMARY KEY (uuid);


--
-- Name: twofactor twofactor_user_uuid_atype_key; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.twofactor
    ADD CONSTRAINT twofactor_user_uuid_atype_key UNIQUE (user_uuid, atype);


--
-- Name: users_collections users_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.users_collections
    ADD CONSTRAINT users_collections_pkey PRIMARY KEY (user_uuid, collection_uuid);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users_organizations users_organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.users_organizations
    ADD CONSTRAINT users_organizations_pkey PRIMARY KEY (uuid);


--
-- Name: users_organizations users_organizations_user_uuid_org_uuid_key; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.users_organizations
    ADD CONSTRAINT users_organizations_user_uuid_org_uuid_key UNIQUE (user_uuid, org_uuid);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (uuid);


--
-- Name: archives archives_cipher_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.archives
    ADD CONSTRAINT archives_cipher_uuid_fkey FOREIGN KEY (cipher_uuid) REFERENCES public.ciphers(uuid) ON DELETE CASCADE;


--
-- Name: archives archives_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.archives
    ADD CONSTRAINT archives_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid) ON DELETE CASCADE;


--
-- Name: attachments attachments_cipher_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_cipher_uuid_fkey FOREIGN KEY (cipher_uuid) REFERENCES public.ciphers(uuid);


--
-- Name: auth_requests auth_requests_organization_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.auth_requests
    ADD CONSTRAINT auth_requests_organization_uuid_fkey FOREIGN KEY (organization_uuid) REFERENCES public.organizations(uuid);


--
-- Name: auth_requests auth_requests_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.auth_requests
    ADD CONSTRAINT auth_requests_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid);


--
-- Name: ciphers_collections ciphers_collections_cipher_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.ciphers_collections
    ADD CONSTRAINT ciphers_collections_cipher_uuid_fkey FOREIGN KEY (cipher_uuid) REFERENCES public.ciphers(uuid);


--
-- Name: ciphers_collections ciphers_collections_collection_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.ciphers_collections
    ADD CONSTRAINT ciphers_collections_collection_uuid_fkey FOREIGN KEY (collection_uuid) REFERENCES public.collections(uuid);


--
-- Name: ciphers ciphers_organization_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.ciphers
    ADD CONSTRAINT ciphers_organization_uuid_fkey FOREIGN KEY (organization_uuid) REFERENCES public.organizations(uuid);


--
-- Name: ciphers ciphers_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.ciphers
    ADD CONSTRAINT ciphers_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid);


--
-- Name: collections_groups collections_groups_collections_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.collections_groups
    ADD CONSTRAINT collections_groups_collections_uuid_fkey FOREIGN KEY (collections_uuid) REFERENCES public.collections(uuid);


--
-- Name: collections_groups collections_groups_groups_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.collections_groups
    ADD CONSTRAINT collections_groups_groups_uuid_fkey FOREIGN KEY (groups_uuid) REFERENCES public.groups(uuid);


--
-- Name: collections collections_org_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_org_uuid_fkey FOREIGN KEY (org_uuid) REFERENCES public.organizations(uuid);


--
-- Name: devices devices_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid);


--
-- Name: emergency_access emergency_access_grantee_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.emergency_access
    ADD CONSTRAINT emergency_access_grantee_uuid_fkey FOREIGN KEY (grantee_uuid) REFERENCES public.users(uuid);


--
-- Name: emergency_access emergency_access_grantor_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.emergency_access
    ADD CONSTRAINT emergency_access_grantor_uuid_fkey FOREIGN KEY (grantor_uuid) REFERENCES public.users(uuid);


--
-- Name: favorites favorites_cipher_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_cipher_uuid_fkey FOREIGN KEY (cipher_uuid) REFERENCES public.ciphers(uuid);


--
-- Name: favorites favorites_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid);


--
-- Name: folders_ciphers folders_ciphers_cipher_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.folders_ciphers
    ADD CONSTRAINT folders_ciphers_cipher_uuid_fkey FOREIGN KEY (cipher_uuid) REFERENCES public.ciphers(uuid);


--
-- Name: folders_ciphers folders_ciphers_folder_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.folders_ciphers
    ADD CONSTRAINT folders_ciphers_folder_uuid_fkey FOREIGN KEY (folder_uuid) REFERENCES public.folders(uuid);


--
-- Name: folders folders_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid);


--
-- Name: groups groups_organizations_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_organizations_uuid_fkey FOREIGN KEY (organizations_uuid) REFERENCES public.organizations(uuid);


--
-- Name: groups_users groups_users_groups_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.groups_users
    ADD CONSTRAINT groups_users_groups_uuid_fkey FOREIGN KEY (groups_uuid) REFERENCES public.groups(uuid);


--
-- Name: groups_users groups_users_users_organizations_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.groups_users
    ADD CONSTRAINT groups_users_users_organizations_uuid_fkey FOREIGN KEY (users_organizations_uuid) REFERENCES public.users_organizations(uuid);


--
-- Name: org_policies org_policies_org_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.org_policies
    ADD CONSTRAINT org_policies_org_uuid_fkey FOREIGN KEY (org_uuid) REFERENCES public.organizations(uuid);


--
-- Name: organization_api_key organization_api_key_org_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.organization_api_key
    ADD CONSTRAINT organization_api_key_org_uuid_fkey FOREIGN KEY (org_uuid) REFERENCES public.organizations(uuid);


--
-- Name: sends sends_organization_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.sends
    ADD CONSTRAINT sends_organization_uuid_fkey FOREIGN KEY (organization_uuid) REFERENCES public.organizations(uuid);


--
-- Name: sends sends_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.sends
    ADD CONSTRAINT sends_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid);


--
-- Name: sso_users sso_users_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.sso_users
    ADD CONSTRAINT sso_users_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: twofactor_incomplete twofactor_incomplete_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.twofactor_incomplete
    ADD CONSTRAINT twofactor_incomplete_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid);


--
-- Name: twofactor twofactor_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.twofactor
    ADD CONSTRAINT twofactor_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid);


--
-- Name: users_collections users_collections_collection_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.users_collections
    ADD CONSTRAINT users_collections_collection_uuid_fkey FOREIGN KEY (collection_uuid) REFERENCES public.collections(uuid);


--
-- Name: users_collections users_collections_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.users_collections
    ADD CONSTRAINT users_collections_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid);


--
-- Name: users_organizations users_organizations_org_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.users_organizations
    ADD CONSTRAINT users_organizations_org_uuid_fkey FOREIGN KEY (org_uuid) REFERENCES public.organizations(uuid);


--
-- Name: users_organizations users_organizations_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vaultwarden
--

ALTER TABLE ONLY public.users_organizations
    ADD CONSTRAINT users_organizations_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.users(uuid);


--
-- PostgreSQL database dump complete
--


