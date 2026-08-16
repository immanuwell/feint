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
-- Name: account_recovery_organization_policies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_recovery_organization_policies (
    id uuid NOT NULL,
    public_key_id uuid,
    policy character varying(36) NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    deleted timestamp without time zone,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


--
-- Name: account_recovery_organization_public_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_recovery_organization_public_keys (
    id uuid NOT NULL,
    armored_key text NOT NULL,
    fingerprint character(40) NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    deleted timestamp without time zone,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


--
-- Name: account_recovery_private_key_passwords; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_recovery_private_key_passwords (
    id uuid NOT NULL,
    recipient_fingerprint character(40) NOT NULL,
    recipient_foreign_model character varying(128) NOT NULL,
    private_key_id uuid NOT NULL,
    data text NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


--
-- Name: account_recovery_private_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_recovery_private_keys (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    data text NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


--
-- Name: account_recovery_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_recovery_requests (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    armored_key text,
    fingerprint character varying(40),
    authentication_token_id uuid NOT NULL,
    status character varying(36) NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


--
-- Name: account_recovery_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_recovery_responses (
    id uuid NOT NULL,
    account_recovery_request_id uuid NOT NULL,
    responder_foreign_key uuid NOT NULL,
    responder_foreign_model character varying(128) NOT NULL,
    data text,
    status character varying(36) NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


--
-- Name: account_recovery_user_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_recovery_user_settings (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    status character varying(36) NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


--
-- Name: account_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_settings (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    property_id uuid NOT NULL,
    property character varying(256) NOT NULL,
    value text,
    created timestamp without time zone,
    modified timestamp without time zone
);


--
-- Name: action_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.action_logs (
    id uuid NOT NULL,
    user_id uuid,
    action_id uuid NOT NULL,
    context character varying(255) NOT NULL,
    status integer NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actions (
    id uuid NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: authentication_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authentication_tokens (
    id uuid NOT NULL,
    token uuid NOT NULL,
    user_id uuid NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    type character varying(16) NOT NULL,
    data text
);


--
-- Name: avatars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.avatars (
    id uuid NOT NULL,
    data bytea,
    profile_id uuid NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id uuid NOT NULL,
    parent_id uuid,
    foreign_key uuid NOT NULL,
    foreign_model character varying(36) NOT NULL,
    content character varying(256) NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL,
    user_id uuid NOT NULL,
    data text
);


--
-- Name: directory_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directory_entries (
    id uuid NOT NULL,
    foreign_model character varying(36) NOT NULL,
    foreign_key uuid,
    directory_name character varying(256) NOT NULL,
    directory_created timestamp without time zone,
    directory_modified timestamp without time zone,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL
);


--
-- Name: directory_ignore; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directory_ignore (
    id uuid NOT NULL,
    foreign_model character varying(36) NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: directory_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directory_relations (
    id uuid NOT NULL,
    parent_key uuid,
    child_key uuid,
    created timestamp without time zone NOT NULL
);


--
-- Name: directory_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directory_reports (
    id uuid NOT NULL,
    parent_id uuid,
    status character varying(36) NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL
);


--
-- Name: directory_reports_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directory_reports_items (
    report_id uuid NOT NULL,
    id uuid NOT NULL,
    status character varying(36) NOT NULL,
    model character varying(36) NOT NULL,
    action character varying(36) NOT NULL,
    data text,
    created timestamp without time zone NOT NULL
);


--
-- Name: email_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_queue (
    id integer NOT NULL,
    email character varying(129) NOT NULL,
    from_name character varying(255),
    from_email character varying(255),
    subject character varying(255) NOT NULL,
    config character varying(30) NOT NULL,
    template character varying(100),
    layout character varying(50) NOT NULL,
    theme character varying(50) NOT NULL,
    format character varying(5) NOT NULL,
    template_vars text NOT NULL,
    headers text,
    sent boolean DEFAULT false NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    send_tries integer DEFAULT 0 NOT NULL,
    send_at timestamp without time zone,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone,
    attachments text,
    error text
);


--
-- Name: email_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.email_queue ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.email_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entities_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entities_history (
    id uuid NOT NULL,
    action_log_id uuid NOT NULL,
    foreign_model character varying(36) NOT NULL,
    foreign_key uuid NOT NULL,
    crud character(1) NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id uuid NOT NULL,
    user_id uuid,
    foreign_key uuid NOT NULL,
    foreign_model character varying(36) NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone
);


--
-- Name: folders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.folders (
    id uuid NOT NULL,
    name character varying(256),
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL,
    metadata text,
    metadata_key_id uuid,
    metadata_key_type character varying(100)
);


--
-- Name: folders_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.folders_history (
    id uuid NOT NULL,
    folder_id uuid NOT NULL,
    name character varying(256)
);


--
-- Name: folders_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.folders_relations (
    id uuid NOT NULL,
    foreign_model character varying(30) NOT NULL,
    foreign_id uuid NOT NULL,
    user_id uuid NOT NULL,
    folder_parent_id uuid,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL
);


--
-- Name: folders_relations_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.folders_relations_history (
    id uuid NOT NULL,
    foreign_model character varying(30) NOT NULL,
    foreign_id uuid NOT NULL,
    user_id uuid NOT NULL,
    folder_parent_id uuid
);


--
-- Name: gpgkeys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpgkeys (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    armored_key text NOT NULL,
    bits integer DEFAULT 2048,
    uid character varying(769),
    key_id character varying(16),
    fingerprint character varying(51) NOT NULL,
    type character varying(16),
    expires timestamp without time zone,
    key_created timestamp without time zone,
    deleted boolean DEFAULT false NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id uuid NOT NULL,
    name character varying(255),
    deleted boolean DEFAULT false NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


--
-- Name: groups_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups_users (
    id uuid NOT NULL,
    group_id uuid,
    user_id uuid,
    is_admin boolean DEFAULT false NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: metadata_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metadata_keys (
    id uuid NOT NULL,
    fingerprint character varying(51) NOT NULL,
    armored_key text NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    expired timestamp without time zone,
    deleted timestamp without time zone,
    created_by uuid,
    modified_by uuid
);


--
-- Name: metadata_private_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metadata_private_keys (
    id uuid NOT NULL,
    metadata_key_id uuid NOT NULL,
    user_id uuid,
    data text NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid,
    modified_by uuid
);


--
-- Name: metadata_session_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metadata_session_keys (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    data text NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL
);


--
-- Name: organization_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_settings (
    id uuid NOT NULL,
    property_id uuid NOT NULL,
    property character varying(256) NOT NULL,
    value text NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id uuid NOT NULL,
    aco character varying(30) NOT NULL,
    aco_foreign_key uuid NOT NULL,
    aro character varying(30) NOT NULL,
    aro_foreign_key uuid,
    type integer NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL
);


--
-- Name: permissions_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions_history (
    id uuid NOT NULL,
    aco character varying(30) NOT NULL,
    aco_foreign_key uuid NOT NULL,
    aro character varying(30) NOT NULL,
    aro_foreign_key uuid NOT NULL,
    type integer NOT NULL
);


--
-- Name: phinxlog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phinxlog (
    version bigint NOT NULL,
    migration_name character varying(100),
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    breakpoint boolean DEFAULT false NOT NULL
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL
);


--
-- Name: rbacs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rbacs (
    id uuid NOT NULL,
    role_id uuid NOT NULL,
    control_function character varying(255),
    foreign_model character varying(36) NOT NULL,
    foreign_id uuid NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid,
    modified_by uuid
);


--
-- Name: resource_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_types (
    id uuid NOT NULL,
    slug character varying(64),
    name character varying(64),
    description character(255),
    definition text,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    deleted timestamp without time zone
);


--
-- Name: resources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resources (
    id uuid NOT NULL,
    name character varying(255),
    username character varying(255),
    uri character varying(1024),
    description text,
    deleted boolean DEFAULT false NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL,
    resource_type_id uuid,
    expired timestamp without time zone,
    metadata text,
    metadata_key_id uuid,
    metadata_key_type character varying(100)
);


--
-- Name: resources_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resources_tags (
    id uuid NOT NULL,
    resource_id uuid NOT NULL,
    tag_id uuid NOT NULL,
    user_id uuid,
    created timestamp without time zone NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(255),
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    deleted timestamp without time zone,
    created_by uuid,
    modified_by uuid,
    deleted_by uuid
);


--
-- Name: scim_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scim_entries (
    id uuid NOT NULL,
    foreign_key uuid,
    foreign_model character varying(36) NOT NULL,
    external_identifier character varying(256),
    scim_name character varying(256),
    deleted timestamp without time zone,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL
);


--
-- Name: secret_accesses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secret_accesses (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    resource_id uuid NOT NULL,
    secret_id uuid NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: secret_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secret_revisions (
    id uuid NOT NULL,
    resource_id uuid NOT NULL,
    resource_type_id uuid NOT NULL,
    deleted timestamp without time zone,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid,
    modified_by uuid
);


--
-- Name: secrets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secrets (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    resource_id uuid NOT NULL,
    data text NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid,
    modified_by uuid,
    deleted timestamp without time zone,
    secret_revision_id uuid
);


--
-- Name: secrets_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secrets_history (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    resource_id uuid NOT NULL
);


--
-- Name: sso_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sso_keys (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    data text,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


--
-- Name: sso_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sso_settings (
    id uuid NOT NULL,
    provider character varying(64) NOT NULL,
    data text,
    status character varying(8) NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    created_by uuid NOT NULL,
    modified_by uuid NOT NULL
);


--
-- Name: sso_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sso_states (
    id uuid NOT NULL,
    nonce character varying(64) NOT NULL,
    type character varying(16) NOT NULL,
    state character varying(64) NOT NULL,
    sso_settings_id uuid NOT NULL,
    user_id uuid,
    user_agent character varying(255) NOT NULL,
    ip character varying(45) NOT NULL,
    created timestamp without time zone NOT NULL,
    deleted timestamp without time zone
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id uuid NOT NULL,
    slug character varying(128),
    is_shared boolean DEFAULT false NOT NULL,
    metadata text,
    metadata_key_id uuid,
    metadata_key_type character varying(100)
);


--
-- Name: transfers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transfers (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    authentication_token_id uuid NOT NULL,
    current_page integer NOT NULL,
    total_pages integer NOT NULL,
    status character varying(16) NOT NULL,
    hash character(128) NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL
);


--
-- Name: ui_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ui_actions (
    id uuid NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    role_id uuid NOT NULL,
    username character varying(255) NOT NULL,
    active boolean DEFAULT false NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    created timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    disabled timestamp without time zone,
    last_logged_in timestamp without time zone
);


--
-- Name: account_recovery_organization_policies account_recovery_organization_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_recovery_organization_policies
    ADD CONSTRAINT account_recovery_organization_policies_pkey PRIMARY KEY (id);


--
-- Name: account_recovery_organization_public_keys account_recovery_organization_public_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_recovery_organization_public_keys
    ADD CONSTRAINT account_recovery_organization_public_keys_pkey PRIMARY KEY (id);


--
-- Name: account_recovery_private_key_passwords account_recovery_private_key_passwords_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_recovery_private_key_passwords
    ADD CONSTRAINT account_recovery_private_key_passwords_pkey PRIMARY KEY (id);


--
-- Name: account_recovery_private_keys account_recovery_private_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_recovery_private_keys
    ADD CONSTRAINT account_recovery_private_keys_pkey PRIMARY KEY (id);


--
-- Name: account_recovery_requests account_recovery_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_recovery_requests
    ADD CONSTRAINT account_recovery_requests_pkey PRIMARY KEY (id);


--
-- Name: account_recovery_responses account_recovery_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_recovery_responses
    ADD CONSTRAINT account_recovery_responses_pkey PRIMARY KEY (id);


--
-- Name: account_recovery_user_settings account_recovery_user_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_recovery_user_settings
    ADD CONSTRAINT account_recovery_user_settings_pkey PRIMARY KEY (id);


--
-- Name: account_settings account_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_settings
    ADD CONSTRAINT account_settings_pkey PRIMARY KEY (id);


--
-- Name: action_logs action_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_logs
    ADD CONSTRAINT action_logs_pkey PRIMARY KEY (id);


--
-- Name: actions actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (id);


--
-- Name: authentication_tokens authentication_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentication_tokens
    ADD CONSTRAINT authentication_tokens_pkey PRIMARY KEY (id);


--
-- Name: avatars avatars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avatars
    ADD CONSTRAINT avatars_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: directory_entries directory_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directory_entries
    ADD CONSTRAINT directory_entries_pkey PRIMARY KEY (id);


--
-- Name: directory_ignore directory_ignore_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directory_ignore
    ADD CONSTRAINT directory_ignore_pkey PRIMARY KEY (id);


--
-- Name: directory_relations directory_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directory_relations
    ADD CONSTRAINT directory_relations_pkey PRIMARY KEY (id);


--
-- Name: directory_reports_items directory_reports_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directory_reports_items
    ADD CONSTRAINT directory_reports_items_pkey PRIMARY KEY (id);


--
-- Name: directory_reports directory_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directory_reports
    ADD CONSTRAINT directory_reports_pkey PRIMARY KEY (id);


--
-- Name: email_queue email_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_queue
    ADD CONSTRAINT email_queue_pkey PRIMARY KEY (id);


--
-- Name: entities_history entities_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities_history
    ADD CONSTRAINT entities_history_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: folders_history folders_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folders_history
    ADD CONSTRAINT folders_history_pkey PRIMARY KEY (id);


--
-- Name: folders folders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_pkey PRIMARY KEY (id);


--
-- Name: folders_relations_history folders_relations_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folders_relations_history
    ADD CONSTRAINT folders_relations_history_pkey PRIMARY KEY (id);


--
-- Name: folders_relations folders_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folders_relations
    ADD CONSTRAINT folders_relations_pkey PRIMARY KEY (id);


--
-- Name: gpgkeys gpgkeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpgkeys
    ADD CONSTRAINT gpgkeys_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: groups_users groups_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_users
    ADD CONSTRAINT groups_users_pkey PRIMARY KEY (id);


--
-- Name: metadata_keys metadata_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metadata_keys
    ADD CONSTRAINT metadata_keys_pkey PRIMARY KEY (id);


--
-- Name: metadata_private_keys metadata_private_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metadata_private_keys
    ADD CONSTRAINT metadata_private_keys_pkey PRIMARY KEY (id);


--
-- Name: metadata_session_keys metadata_session_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metadata_session_keys
    ADD CONSTRAINT metadata_session_keys_pkey PRIMARY KEY (id);


--
-- Name: organization_settings organization_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_settings
    ADD CONSTRAINT organization_settings_pkey PRIMARY KEY (id);


--
-- Name: permissions_history permissions_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions_history
    ADD CONSTRAINT permissions_history_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: phinxlog phinxlog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phinxlog
    ADD CONSTRAINT phinxlog_pkey PRIMARY KEY (version);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: rbacs rbacs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rbacs
    ADD CONSTRAINT rbacs_pkey PRIMARY KEY (id);


--
-- Name: resource_types resource_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_types
    ADD CONSTRAINT resource_types_pkey PRIMARY KEY (id);


--
-- Name: resources resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- Name: resources_tags resources_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resources_tags
    ADD CONSTRAINT resources_tags_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: scim_entries scim_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scim_entries
    ADD CONSTRAINT scim_entries_pkey PRIMARY KEY (id);


--
-- Name: secret_accesses secret_accesses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secret_accesses
    ADD CONSTRAINT secret_accesses_pkey PRIMARY KEY (id);


--
-- Name: secret_revisions secret_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secret_revisions
    ADD CONSTRAINT secret_revisions_pkey PRIMARY KEY (id);


--
-- Name: secrets_history secrets_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secrets_history
    ADD CONSTRAINT secrets_history_pkey PRIMARY KEY (id);


--
-- Name: secrets secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secrets
    ADD CONSTRAINT secrets_pkey PRIMARY KEY (id);


--
-- Name: sso_keys sso_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sso_keys
    ADD CONSTRAINT sso_keys_pkey PRIMARY KEY (id);


--
-- Name: sso_settings sso_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sso_settings
    ADD CONSTRAINT sso_settings_pkey PRIMARY KEY (id);


--
-- Name: sso_states sso_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sso_states
    ADD CONSTRAINT sso_states_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: transfers transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transfers
    ADD CONSTRAINT transfers_pkey PRIMARY KEY (id);


--
-- Name: ui_actions ui_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ui_actions
    ADD CONSTRAINT ui_actions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: account_recovery_organization_policies_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_recovery_organization_policies_id ON public.account_recovery_organization_policies USING btree (id);


--
-- Name: account_recovery_organization_policies_public_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_recovery_organization_policies_public_key_id ON public.account_recovery_organization_policies USING btree (public_key_id);


--
-- Name: account_recovery_organization_public_keys_fingerprint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_recovery_organization_public_keys_fingerprint ON public.account_recovery_organization_public_keys USING btree (fingerprint);


--
-- Name: account_recovery_organization_public_keys_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_recovery_organization_public_keys_id ON public.account_recovery_organization_public_keys USING btree (id);


--
-- Name: account_recovery_private_key_passwords_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_recovery_private_key_passwords_id ON public.account_recovery_private_key_passwords USING btree (id);


--
-- Name: account_recovery_private_key_passwords_recipient_fingerprint; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_recovery_private_key_passwords_recipient_fingerprint ON public.account_recovery_private_key_passwords USING btree (recipient_fingerprint);


--
-- Name: account_recovery_private_keys_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_recovery_private_keys_id ON public.account_recovery_private_keys USING btree (id);


--
-- Name: account_recovery_private_keys_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_recovery_private_keys_user_id ON public.account_recovery_private_keys USING btree (user_id);


--
-- Name: account_recovery_requests_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_recovery_requests_id ON public.account_recovery_requests USING btree (id);


--
-- Name: account_recovery_responses_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_recovery_responses_id ON public.account_recovery_responses USING btree (id);


--
-- Name: account_recovery_user_settings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_recovery_user_settings_id ON public.account_recovery_user_settings USING btree (id);


--
-- Name: account_recovery_user_settings_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_recovery_user_settings_user_id ON public.account_recovery_user_settings USING btree (user_id);


--
-- Name: account_settings_user_id_property_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_settings_user_id_property_id ON public.account_settings USING btree (user_id, property_id);


--
-- Name: action_logs_action_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX action_logs_action_id_status ON public.action_logs USING btree (action_id, status);


--
-- Name: action_logs_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX action_logs_id ON public.action_logs USING btree (id);


--
-- Name: action_logs_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX action_logs_status ON public.action_logs USING btree (status);


--
-- Name: action_logs_user_id_action_id_status_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX action_logs_user_id_action_id_status_created ON public.action_logs USING btree (user_id, action_id, status, created);


--
-- Name: actions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actions_id ON public.actions USING btree (id);


--
-- Name: actions_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actions_name ON public.actions USING btree (name);


--
-- Name: authentication_tokens_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authentication_tokens_type ON public.authentication_tokens USING btree (type);


--
-- Name: authentication_tokens_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authentication_tokens_user_id ON public.authentication_tokens USING btree (user_id);


--
-- Name: avatars_profile_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX avatars_profile_id ON public.avatars USING btree (profile_id);


--
-- Name: comments_parent_id_foreign_model_created_by_modified_by_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_parent_id_foreign_model_created_by_modified_by_user_id ON public.comments USING btree (parent_id, foreign_model, created_by, modified_by, user_id);


--
-- Name: directory_entries_id_foreign_model_foreign_key_directory_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX directory_entries_id_foreign_model_foreign_key_directory_name ON public.directory_entries USING btree (id, foreign_model, foreign_key, directory_name);


--
-- Name: directory_ignore_id_foreign_model; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX directory_ignore_id_foreign_model ON public.directory_ignore USING btree (id, foreign_model);


--
-- Name: directory_relations_id_parent_key_child_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX directory_relations_id_parent_key_child_key ON public.directory_relations USING btree (id, parent_key, child_key);


--
-- Name: directory_reports_id_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX directory_reports_id_parent_id ON public.directory_reports USING btree (id, parent_id);


--
-- Name: directory_reports_items_id_status_model_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX directory_reports_items_id_status_model_action ON public.directory_reports_items USING btree (id, status, model, action);


--
-- Name: entities_history_action_log_id_foreign_model_foreign_key_crud; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entities_history_action_log_id_foreign_model_foreign_key_crud ON public.entities_history USING btree (action_log_id, foreign_model, foreign_key, crud);


--
-- Name: entities_history_foreign_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entities_history_foreign_key ON public.entities_history USING btree (foreign_key);


--
-- Name: entities_history_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entities_history_id ON public.entities_history USING btree (id);


--
-- Name: favorites_foreign_key_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX favorites_foreign_key_user_id ON public.favorites USING btree (foreign_key, user_id);


--
-- Name: favorites_user_id_foreign_model; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX favorites_user_id_foreign_model ON public.favorites USING btree (user_id, foreign_model);


--
-- Name: folders_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX folders_name ON public.folders USING btree (name);


--
-- Name: folders_relations_folder_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX folders_relations_folder_parent_id ON public.folders_relations USING btree (folder_parent_id);


--
-- Name: folders_relations_foreign_id_folder_parent_id_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX folders_relations_foreign_id_folder_parent_id_created ON public.folders_relations USING btree (foreign_id, folder_parent_id, created);


--
-- Name: folders_relations_foreign_model_folder_parent_id_foreign_id_use; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX folders_relations_foreign_model_folder_parent_id_foreign_id_use ON public.folders_relations USING btree (foreign_model, folder_parent_id, foreign_id, user_id);


--
-- Name: folders_relations_foreign_model_folder_parent_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX folders_relations_foreign_model_folder_parent_id_user_id ON public.folders_relations USING btree (foreign_model, folder_parent_id, user_id);


--
-- Name: folders_relations_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX folders_relations_user_id ON public.folders_relations USING btree (user_id);


--
-- Name: folders_relations_user_id_foreign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX folders_relations_user_id_foreign_id ON public.folders_relations USING btree (user_id, foreign_id);


--
-- Name: gpgkeys_fingerprint; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX gpgkeys_fingerprint ON public.gpgkeys USING btree (fingerprint);


--
-- Name: gpgkeys_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX gpgkeys_user_id ON public.gpgkeys USING btree (user_id);


--
-- Name: groups_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX groups_deleted ON public.groups USING btree (deleted);


--
-- Name: groups_users_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX groups_users_group_id ON public.groups_users USING btree (group_id);


--
-- Name: groups_users_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX groups_users_user_id ON public.groups_users USING btree (user_id);


--
-- Name: groups_users_user_id_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX groups_users_user_id_group_id ON public.groups_users USING btree (user_id, group_id);


--
-- Name: metadata_keys_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX metadata_keys_created_by ON public.metadata_keys USING btree (created_by);


--
-- Name: metadata_keys_modified_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX metadata_keys_modified_by ON public.metadata_keys USING btree (modified_by);


--
-- Name: metadata_private_keys_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX metadata_private_keys_created_by ON public.metadata_private_keys USING btree (created_by);


--
-- Name: metadata_private_keys_metadata_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX metadata_private_keys_metadata_key_id ON public.metadata_private_keys USING btree (metadata_key_id);


--
-- Name: metadata_private_keys_modified_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX metadata_private_keys_modified_by ON public.metadata_private_keys USING btree (modified_by);


--
-- Name: metadata_private_keys_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX metadata_private_keys_user_id ON public.metadata_private_keys USING btree (user_id);


--
-- Name: metadata_session_keys_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX metadata_session_keys_user_id ON public.metadata_session_keys USING btree (user_id);


--
-- Name: organization_settings_property_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_settings_property_id ON public.organization_settings USING btree (property_id);


--
-- Name: permissions_aco_foreign_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_aco_foreign_key ON public.permissions USING btree (aco_foreign_key);


--
-- Name: permissions_aco_foreign_key_aro_foreign_key_aco_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_aco_foreign_key_aro_foreign_key_aco_type ON public.permissions USING btree (aco_foreign_key, aro_foreign_key, aco, type);


--
-- Name: permissions_aro_foreign_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_aro_foreign_key ON public.permissions USING btree (aro_foreign_key);


--
-- Name: permissions_history_aco_aro; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_history_aco_aro ON public.permissions_history USING btree (aco, aro);


--
-- Name: permissions_history_aco_foreign_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_history_aco_foreign_key ON public.permissions_history USING btree (aco_foreign_key);


--
-- Name: permissions_history_aro_foreign_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_history_aro_foreign_key ON public.permissions_history USING btree (aro_foreign_key);


--
-- Name: permissions_history_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_history_type ON public.permissions_history USING btree (type);


--
-- Name: profiles_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX profiles_user_id ON public.profiles USING btree (user_id);


--
-- Name: rbacs_role_id_foreign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rbacs_role_id_foreign_id ON public.rbacs USING btree (role_id, foreign_id);


--
-- Name: resource_types_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX resource_types_slug ON public.resource_types USING btree (slug);


--
-- Name: resources_created_by_modified_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resources_created_by_modified_by ON public.resources USING btree (created_by, modified_by);


--
-- Name: resources_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resources_deleted ON public.resources USING btree (deleted);


--
-- Name: resources_resource_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resources_resource_type_id ON public.resources USING btree (resource_type_id);


--
-- Name: resources_tags_tag_id_user_id_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resources_tags_tag_id_user_id_resource_id ON public.resources_tags USING btree (tag_id, user_id, resource_id);


--
-- Name: scim_entries_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scim_entries_created ON public.scim_entries USING btree (created);


--
-- Name: scim_entries_external_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scim_entries_external_identifier ON public.scim_entries USING btree (external_identifier);


--
-- Name: scim_entries_foreign_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scim_entries_foreign_key ON public.scim_entries USING btree (foreign_key);


--
-- Name: scim_entries_foreign_model; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scim_entries_foreign_model ON public.scim_entries USING btree (foreign_model);


--
-- Name: scim_entries_scim_name_active_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX scim_entries_scim_name_active_uniq ON public.scim_entries USING btree (scim_name, foreign_model) WHERE (deleted IS NULL);


--
-- Name: secret_accesses_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secret_accesses_id ON public.secret_accesses USING btree (id);


--
-- Name: secret_accesses_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secret_accesses_resource_id ON public.secret_accesses USING btree (resource_id);


--
-- Name: secret_accesses_secret_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secret_accesses_secret_id ON public.secret_accesses USING btree (secret_id);


--
-- Name: secret_accesses_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secret_accesses_user_id ON public.secret_accesses USING btree (user_id);


--
-- Name: secret_accesses_user_id_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secret_accesses_user_id_resource_id ON public.secret_accesses USING btree (user_id, resource_id);


--
-- Name: secret_revisions_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secret_revisions_resource_id ON public.secret_revisions USING btree (resource_id);


--
-- Name: secrets_history_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secrets_history_id ON public.secrets_history USING btree (id);


--
-- Name: secrets_history_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secrets_history_resource_id ON public.secrets_history USING btree (resource_id);


--
-- Name: secrets_history_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secrets_history_user_id ON public.secrets_history USING btree (user_id);


--
-- Name: secrets_history_user_id_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secrets_history_user_id_resource_id ON public.secrets_history USING btree (user_id, resource_id);


--
-- Name: secrets_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secrets_resource_id ON public.secrets USING btree (resource_id);


--
-- Name: secrets_user_id_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secrets_user_id_resource_id ON public.secrets USING btree (user_id, resource_id);


--
-- Name: sso_keys_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sso_keys_id ON public.sso_keys USING btree (id);


--
-- Name: sso_settings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sso_settings_id ON public.sso_settings USING btree (id);


--
-- Name: sso_states_nonce; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sso_states_nonce ON public.sso_states USING btree (nonce);


--
-- Name: sso_states_sso_settings_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sso_states_sso_settings_id_user_id ON public.sso_states USING btree (sso_settings_id, user_id);


--
-- Name: sso_states_state; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sso_states_state ON public.sso_states USING btree (state);


--
-- Name: tags_id_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tags_id_slug ON public.tags USING btree (id, slug);


--
-- Name: transfers_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX transfers_id ON public.transfers USING btree (id);


--
-- Name: users_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_deleted ON public.users USING btree (deleted);


--
-- Name: users_role_id_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_role_id_username ON public.users USING btree (role_id, username);


--
-- PostgreSQL database dump complete
--


