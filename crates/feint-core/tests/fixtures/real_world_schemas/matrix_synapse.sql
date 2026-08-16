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
-- Name: check_event_stream_ordering(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_event_stream_ordering() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                IF EXISTS (
                    SELECT 1 FROM events
                    WHERE events.event_id = NEW.event_id
                       AND events.stream_ordering != NEW.event_stream_ordering
                ) THEN
                    RAISE EXCEPTION 'Incorrect event_stream_ordering';
                END IF;
                RETURN NEW;
            END;
            $$;


--
-- Name: check_partial_state_events(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_partial_state_events() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                IF EXISTS (
                    SELECT 1 FROM events
                    WHERE events.event_id = NEW.event_id
                       AND events.room_id != NEW.room_id
                ) THEN
                    RAISE EXCEPTION 'Incorrect room_id in partial_state_events';
                END IF;
                RETURN NEW;
            END;
            $$;


--
-- Name: delete_read_write_lock_parent(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_read_write_lock_parent() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_token TEXT;
    mode_row_token TEXT;
BEGIN
    -- Only update the token in `_mode` if its our token. This prevents
    -- deadlocks.
    --
    -- We shove the token into `mode_row_token`, as otherwise postgres complains
    -- we're not using the returned data.
    SELECT token INTO mode_row_token FROM worker_read_write_locks_mode
        WHERE
            lock_name = OLD.lock_name
            AND lock_key = OLD.lock_key
            AND token = OLD.token
        FOR UPDATE;

    IF NOT FOUND THEN
        RETURN NEW;
    END IF;

    SELECT token INTO new_token FROM worker_read_write_locks
        WHERE
            lock_name = OLD.lock_name
            AND lock_key = OLD.lock_key
        LIMIT 1 FOR UPDATE SKIP LOCKED;

    IF NOT FOUND THEN
        DELETE FROM worker_read_write_locks_mode
            WHERE lock_name = OLD.lock_name AND lock_key = OLD.lock_key AND token = OLD.token;
    ELSE
        UPDATE worker_read_write_locks_mode
            SET token = new_token
            WHERE lock_name = OLD.lock_name AND lock_key = OLD.lock_key;
    END IF;

    RETURN NEW;
END
$$;


--
-- Name: upsert_read_write_lock_parent(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.upsert_read_write_lock_parent() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO worker_read_write_locks_mode (lock_name, lock_key, write_lock, token)
        VALUES (NEW.lock_name, NEW.lock_key, NEW.write_lock, NEW.token)
        ON CONFLICT (lock_name, lock_key)
        DO UPDATE SET write_lock = NEW.write_lock
            WHERE OLD.write_lock != NEW.write_lock;
    RETURN NEW;
END
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_tokens (
    id bigint NOT NULL,
    user_id text NOT NULL,
    device_id text,
    token text NOT NULL,
    valid_until_ms bigint,
    puppets_user_id text,
    last_validated bigint,
    refresh_token_id bigint,
    used boolean
);


--
-- Name: account_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_data (
    user_id text NOT NULL,
    account_data_type text NOT NULL,
    stream_id bigint NOT NULL,
    content text NOT NULL,
    instance_name text
);


--
-- Name: account_data_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_data_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_validity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_validity (
    user_id text NOT NULL,
    expiration_ts_ms bigint NOT NULL,
    email_sent boolean NOT NULL,
    renewal_token text,
    token_used_ts_ms bigint
);


--
-- Name: application_services_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_services_state (
    as_id text NOT NULL,
    state character varying(5),
    read_receipt_stream_id bigint,
    presence_stream_id bigint,
    to_device_stream_id bigint,
    device_list_stream_id bigint
);


--
-- Name: application_services_txn_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.application_services_txn_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: application_services_txns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_services_txns (
    as_id text NOT NULL,
    txn_id bigint NOT NULL,
    event_ids text NOT NULL
);


--
-- Name: applied_module_schemas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.applied_module_schemas (
    module_name text NOT NULL,
    file text NOT NULL
);


--
-- Name: applied_schema_deltas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.applied_schema_deltas (
    version integer NOT NULL,
    file text NOT NULL
);


--
-- Name: appservice_room_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appservice_room_list (
    appservice_id text NOT NULL,
    network_id text NOT NULL,
    room_id text NOT NULL
);


--
-- Name: appservice_stream_position; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appservice_stream_position (
    lock character(1) DEFAULT 'X'::bpchar NOT NULL,
    stream_ordering bigint,
    CONSTRAINT appservice_stream_position_lock_check CHECK ((lock = 'X'::bpchar))
);


--
-- Name: background_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.background_updates (
    update_name text NOT NULL,
    progress_json text NOT NULL,
    depends_on text,
    ordering integer DEFAULT 0 NOT NULL
);


--
-- Name: blocked_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocked_rooms (
    room_id text NOT NULL,
    user_id text NOT NULL
);


--
-- Name: cache_invalidation_stream_by_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_invalidation_stream_by_instance (
    stream_id bigint NOT NULL,
    instance_name text NOT NULL,
    cache_func text NOT NULL,
    keys text[],
    invalidation_ts bigint
);


--
-- Name: cache_invalidation_stream_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cache_invalidation_stream_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: current_state_delta_stream; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.current_state_delta_stream (
    stream_id bigint NOT NULL,
    room_id text NOT NULL,
    type text NOT NULL,
    state_key text NOT NULL,
    event_id text,
    prev_event_id text,
    instance_name text
);


--
-- Name: current_state_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.current_state_events (
    event_id text NOT NULL,
    room_id text NOT NULL,
    type text NOT NULL,
    state_key text NOT NULL,
    membership text,
    event_stream_ordering bigint
);


--
-- Name: dehydrated_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dehydrated_devices (
    user_id text NOT NULL,
    device_id text NOT NULL,
    device_data text NOT NULL
);


--
-- Name: delayed_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_events (
    delay_id text NOT NULL,
    user_localpart text NOT NULL,
    device_id text,
    delay bigint NOT NULL,
    send_ts bigint NOT NULL,
    room_id text NOT NULL,
    event_type text NOT NULL,
    state_key text,
    origin_server_ts bigint,
    content text NOT NULL,
    is_processed boolean DEFAULT false NOT NULL,
    sticky_duration_ms bigint
);


--
-- Name: delayed_events_stream_pos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_events_stream_pos (
    lock character(1) DEFAULT 'X'::bpchar NOT NULL,
    stream_id bigint NOT NULL,
    CONSTRAINT delayed_events_stream_pos_lock_check CHECK ((lock = 'X'::bpchar))
);


--
-- Name: deleted_pushers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleted_pushers (
    stream_id bigint NOT NULL,
    app_id text NOT NULL,
    pushkey text NOT NULL,
    user_id text NOT NULL,
    instance_name text
);


--
-- Name: destination_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.destination_rooms (
    destination text NOT NULL,
    room_id text NOT NULL,
    stream_ordering bigint NOT NULL
);


--
-- Name: TABLE destination_rooms; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.destination_rooms IS 'Information about transmission of PDUs in a given room to a given remote homeserver.';


--
-- Name: COLUMN destination_rooms.destination; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.destination_rooms.destination IS 'server name of remote homeserver in question';


--
-- Name: COLUMN destination_rooms.room_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.destination_rooms.room_id IS 'room ID in question';


--
-- Name: COLUMN destination_rooms.stream_ordering; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.destination_rooms.stream_ordering IS '`stream_ordering` of the most recent PDU in this room that needs to be sent (by us) to this homeserver.
This can only be pointing to our own PDU because we are only responsible for sending our own PDUs.';


--
-- Name: destinations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.destinations (
    destination text NOT NULL,
    retry_last_ts bigint,
    retry_interval bigint,
    failure_ts bigint,
    last_successful_stream_ordering bigint
);


--
-- Name: TABLE destinations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.destinations IS 'Information about remote homeservers and the health of our connection to them.';


--
-- Name: COLUMN destinations.destination; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.destinations.destination IS 'server name of remote homeserver in question';


--
-- Name: COLUMN destinations.retry_last_ts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.destinations.retry_last_ts IS 'The last time we tried and failed to reach the remote server, in ms.
This field is reset to `0` when we succeed in connecting again.';


--
-- Name: COLUMN destinations.retry_interval; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.destinations.retry_interval IS 'How long, in milliseconds, to wait since the last time we tried to reach the remote server before trying again.
This field is reset to `0` when we succeed in connecting again.';


--
-- Name: COLUMN destinations.failure_ts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.destinations.failure_ts IS 'The first time we tried and failed to reach the remote server, in ms.
This field is reset to `NULL` when we succeed in connecting again.';


--
-- Name: COLUMN destinations.last_successful_stream_ordering; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.destinations.last_successful_stream_ordering IS 'Stream ordering of the most recently successfully sent PDU to this server, sent through normal send (not e.g. backfill).
In Catch-Up Mode, the original PDU persisted by us is represented here, even if we sent a later forward extremity in its stead.
See `destination_rooms` for more information about catch-up.';


--
-- Name: device_auth_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_auth_providers (
    user_id text NOT NULL,
    device_id text NOT NULL,
    auth_provider_id text NOT NULL,
    auth_provider_session_id text NOT NULL
);


--
-- Name: device_federation_inbox; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_federation_inbox (
    origin text NOT NULL,
    message_id text NOT NULL,
    received_ts bigint NOT NULL,
    instance_name text
);


--
-- Name: device_federation_outbox; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_federation_outbox (
    destination text NOT NULL,
    stream_id bigint NOT NULL,
    queued_ts bigint NOT NULL,
    messages_json text NOT NULL,
    instance_name text
);


--
-- Name: device_inbox; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_inbox (
    user_id text NOT NULL,
    device_id text NOT NULL,
    stream_id bigint NOT NULL,
    message_json text NOT NULL,
    instance_name text
);


--
-- Name: device_inbox_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.device_inbox_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: device_lists_changes_converted_stream_position; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_lists_changes_converted_stream_position (
    lock character(1) DEFAULT 'X'::bpchar NOT NULL,
    stream_id bigint NOT NULL,
    room_id text NOT NULL,
    instance_name text,
    CONSTRAINT device_lists_changes_converted_stream_position_lock_check CHECK ((lock = 'X'::bpchar))
);


--
-- Name: device_lists_changes_in_room; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_lists_changes_in_room (
    user_id text NOT NULL,
    device_id text NOT NULL,
    room_id text NOT NULL,
    stream_id bigint NOT NULL,
    converted_to_destinations boolean NOT NULL,
    opentracing_context text,
    instance_name text,
    inserted_ts bigint
);


--
-- Name: device_lists_changes_in_room_max_pruned_stream_id; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_lists_changes_in_room_max_pruned_stream_id (
    lock character(1) DEFAULT 'X'::bpchar NOT NULL,
    stream_id bigint NOT NULL
);


--
-- Name: device_lists_outbound_last_success; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_lists_outbound_last_success (
    destination text NOT NULL,
    user_id text NOT NULL,
    stream_id bigint NOT NULL
);


--
-- Name: device_lists_outbound_pokes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_lists_outbound_pokes (
    destination text NOT NULL,
    stream_id bigint NOT NULL,
    user_id text NOT NULL,
    device_id text NOT NULL,
    sent boolean NOT NULL,
    ts bigint NOT NULL,
    opentracing_context text,
    instance_name text
);


--
-- Name: device_lists_remote_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_lists_remote_cache (
    user_id text NOT NULL,
    device_id text NOT NULL,
    content text NOT NULL
);


--
-- Name: device_lists_remote_extremeties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_lists_remote_extremeties (
    user_id text NOT NULL,
    stream_id text NOT NULL
);


--
-- Name: device_lists_remote_pending; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_lists_remote_pending (
    stream_id bigint NOT NULL,
    user_id text NOT NULL,
    device_id text NOT NULL,
    instance_name text
);


--
-- Name: device_lists_remote_resync; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_lists_remote_resync (
    user_id text NOT NULL,
    added_ts bigint NOT NULL
);


--
-- Name: device_lists_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.device_lists_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: device_lists_stream; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_lists_stream (
    stream_id bigint NOT NULL,
    user_id text NOT NULL,
    device_id text NOT NULL,
    instance_name text
);


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.devices (
    user_id text NOT NULL,
    device_id text NOT NULL,
    display_name text,
    last_seen bigint,
    ip text,
    user_agent text,
    hidden boolean DEFAULT false
);


--
-- Name: e2e_cross_signing_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.e2e_cross_signing_keys (
    user_id text NOT NULL,
    keytype text NOT NULL,
    keydata text NOT NULL,
    stream_id bigint NOT NULL,
    updatable_without_uia_before_ms bigint,
    instance_name text
);


--
-- Name: e2e_cross_signing_keys_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.e2e_cross_signing_keys_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: e2e_cross_signing_signatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.e2e_cross_signing_signatures (
    user_id text NOT NULL,
    key_id text NOT NULL,
    target_user_id text NOT NULL,
    target_device_id text NOT NULL,
    signature text NOT NULL
);


--
-- Name: e2e_device_keys_json; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.e2e_device_keys_json (
    user_id text NOT NULL,
    device_id text NOT NULL,
    ts_added_ms bigint NOT NULL,
    key_json text NOT NULL
);


--
-- Name: e2e_fallback_keys_json; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.e2e_fallback_keys_json (
    user_id text NOT NULL,
    device_id text NOT NULL,
    algorithm text NOT NULL,
    key_id text NOT NULL,
    key_json text NOT NULL,
    used boolean DEFAULT false NOT NULL
);


--
-- Name: e2e_one_time_keys_json; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.e2e_one_time_keys_json (
    user_id text NOT NULL,
    device_id text NOT NULL,
    algorithm text NOT NULL,
    key_id text NOT NULL,
    ts_added_ms bigint NOT NULL,
    key_json text NOT NULL
);


--
-- Name: e2e_room_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.e2e_room_keys (
    user_id text NOT NULL,
    room_id text NOT NULL,
    session_id text NOT NULL,
    version bigint NOT NULL,
    first_message_index integer,
    forwarded_count integer,
    is_verified boolean,
    session_data text NOT NULL
);


--
-- Name: e2e_room_keys_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.e2e_room_keys_versions (
    user_id text NOT NULL,
    version bigint NOT NULL,
    algorithm text NOT NULL,
    auth_data text NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    etag bigint
);


--
-- Name: erased_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.erased_users (
    user_id text NOT NULL
);


--
-- Name: event_auth; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_auth (
    event_id text NOT NULL,
    auth_id text NOT NULL,
    room_id text NOT NULL
);


--
-- Name: event_auth_chain_id; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_auth_chain_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_auth_chain_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_auth_chain_links (
    origin_chain_id bigint NOT NULL,
    origin_sequence_number bigint NOT NULL,
    target_chain_id bigint NOT NULL,
    target_sequence_number bigint NOT NULL
);
ALTER TABLE ONLY public.event_auth_chain_links ALTER COLUMN origin_chain_id SET (n_distinct=-0.5);
ALTER TABLE ONLY public.event_auth_chain_links ALTER COLUMN target_chain_id SET (n_distinct=-0.5);


--
-- Name: event_auth_chain_to_calculate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_auth_chain_to_calculate (
    event_id text NOT NULL,
    room_id text NOT NULL,
    type text NOT NULL,
    state_key text NOT NULL
);


--
-- Name: event_auth_chains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_auth_chains (
    event_id text NOT NULL,
    chain_id bigint NOT NULL,
    sequence_number bigint NOT NULL
);


--
-- Name: event_backward_extremities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_backward_extremities (
    event_id text NOT NULL,
    room_id text NOT NULL
);


--
-- Name: event_edges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_edges (
    event_id text NOT NULL,
    prev_event_id text NOT NULL,
    room_id text,
    is_state boolean DEFAULT false NOT NULL
);


--
-- Name: event_expiry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_expiry (
    event_id text NOT NULL,
    expiry_ts bigint NOT NULL
);


--
-- Name: event_failed_pull_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_failed_pull_attempts (
    room_id text NOT NULL,
    event_id text NOT NULL,
    num_attempts integer NOT NULL,
    last_attempt_ts bigint NOT NULL,
    last_cause text NOT NULL
);


--
-- Name: event_forward_extremities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_forward_extremities (
    event_id text NOT NULL,
    room_id text NOT NULL
);


--
-- Name: event_json; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_json (
    event_id text NOT NULL,
    room_id text NOT NULL,
    internal_metadata text NOT NULL,
    json text NOT NULL,
    format_version integer
);


--
-- Name: event_labels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_labels (
    event_id text NOT NULL,
    label text NOT NULL,
    room_id text NOT NULL,
    topological_ordering bigint NOT NULL
);


--
-- Name: event_push_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_push_actions (
    room_id text NOT NULL,
    event_id text NOT NULL,
    user_id text NOT NULL,
    profile_tag character varying(32),
    actions text NOT NULL,
    topological_ordering bigint,
    stream_ordering bigint,
    notif smallint,
    highlight smallint,
    unread smallint,
    thread_id text,
    CONSTRAINT event_push_actions_thread_id CHECK ((thread_id IS NOT NULL))
);


--
-- Name: event_push_actions_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_push_actions_staging (
    event_id text NOT NULL,
    user_id text NOT NULL,
    actions text NOT NULL,
    notif smallint NOT NULL,
    highlight smallint NOT NULL,
    unread smallint,
    thread_id text,
    inserted_ts bigint DEFAULT (EXTRACT(epoch FROM now()) * (1000)::numeric),
    CONSTRAINT event_push_actions_staging_thread_id CHECK ((thread_id IS NOT NULL))
);


--
-- Name: event_push_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_push_summary (
    user_id text NOT NULL,
    room_id text NOT NULL,
    notif_count bigint NOT NULL,
    stream_ordering bigint NOT NULL,
    unread_count bigint,
    last_receipt_stream_ordering bigint,
    thread_id text
);


--
-- Name: event_push_summary_last_receipt_stream_id; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_push_summary_last_receipt_stream_id (
    lock character(1) DEFAULT 'X'::bpchar NOT NULL,
    stream_id bigint NOT NULL,
    CONSTRAINT event_push_summary_last_receipt_stream_id_lock_check CHECK ((lock = 'X'::bpchar))
);


--
-- Name: event_push_summary_stream_ordering; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_push_summary_stream_ordering (
    lock character(1) DEFAULT 'X'::bpchar NOT NULL,
    stream_ordering bigint NOT NULL,
    CONSTRAINT event_push_summary_stream_ordering_lock_check CHECK ((lock = 'X'::bpchar))
);


--
-- Name: event_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_relations (
    event_id text NOT NULL,
    relates_to_id text NOT NULL,
    relation_type text NOT NULL,
    aggregation_key text
);


--
-- Name: event_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_reports (
    id bigint NOT NULL,
    received_ts bigint NOT NULL,
    room_id text NOT NULL,
    event_id text NOT NULL,
    user_id text NOT NULL,
    reason text,
    content text
);


--
-- Name: event_search; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_search (
    event_id text,
    room_id text,
    sender text,
    key text,
    vector tsvector,
    origin_server_ts bigint,
    stream_ordering bigint
);
ALTER TABLE ONLY public.event_search ALTER COLUMN room_id SET (n_distinct=-0.01);


--
-- Name: event_to_state_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_to_state_groups (
    event_id text NOT NULL,
    state_group bigint NOT NULL
);


--
-- Name: event_txn_id_device_id; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_txn_id_device_id (
    event_id text NOT NULL,
    room_id text NOT NULL,
    user_id text NOT NULL,
    device_id text NOT NULL,
    txn_id text NOT NULL,
    inserted_ts bigint NOT NULL
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    topological_ordering bigint NOT NULL,
    event_id text NOT NULL,
    type text NOT NULL,
    room_id text NOT NULL,
    content text,
    unrecognized_keys text,
    processed boolean NOT NULL,
    outlier boolean NOT NULL,
    depth bigint DEFAULT 0 NOT NULL,
    origin_server_ts bigint,
    received_ts bigint,
    sender text,
    contains_url boolean,
    instance_name text,
    stream_ordering bigint,
    state_key text,
    rejection_reason text
);


--
-- Name: events_backfill_stream_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_backfill_stream_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_stream_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_stream_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ex_outlier_stream; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ex_outlier_stream (
    event_stream_ordering bigint NOT NULL,
    event_id text NOT NULL,
    state_group bigint NOT NULL,
    instance_name text
);


--
-- Name: federation_inbound_events_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.federation_inbound_events_staging (
    origin text NOT NULL,
    room_id text NOT NULL,
    event_id text NOT NULL,
    received_ts bigint NOT NULL,
    event_json text NOT NULL,
    internal_metadata text NOT NULL
);


--
-- Name: federation_stream_position; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.federation_stream_position (
    type text NOT NULL,
    stream_id bigint NOT NULL,
    instance_name text DEFAULT 'master'::text NOT NULL
);


--
-- Name: ignored_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ignored_users (
    ignorer_user_id text NOT NULL,
    ignored_user_id text NOT NULL
);


--
-- Name: instance_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instance_map (
    instance_id integer NOT NULL,
    instance_name text NOT NULL
);


--
-- Name: instance_map_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.instance_map_instance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instance_map_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.instance_map_instance_id_seq OWNED BY public.instance_map.instance_id;


--
-- Name: local_current_membership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_current_membership (
    room_id text NOT NULL,
    user_id text NOT NULL,
    event_id text NOT NULL,
    membership text NOT NULL,
    event_stream_ordering bigint
);


--
-- Name: local_media_repository; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_media_repository (
    media_id text,
    media_type text,
    media_length integer,
    created_ts bigint,
    upload_name text,
    user_id text,
    quarantined_by text,
    url_cache text,
    last_access_ts bigint,
    safe_from_quarantine boolean DEFAULT false NOT NULL,
    authenticated boolean DEFAULT false NOT NULL,
    sha256 text
);


--
-- Name: local_media_repository_thumbnails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_media_repository_thumbnails (
    media_id text,
    thumbnail_width integer,
    thumbnail_height integer,
    thumbnail_type text,
    thumbnail_method text,
    thumbnail_length integer
);


--
-- Name: local_media_repository_url_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_media_repository_url_cache (
    url text,
    response_code integer,
    etag text,
    expires_ts bigint,
    og text,
    media_id text,
    download_ts bigint
);


--
-- Name: login_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.login_tokens (
    token text NOT NULL,
    user_id text NOT NULL,
    expiry_ts bigint NOT NULL,
    used_ts bigint,
    auth_provider_id text,
    auth_provider_session_id text
);


--
-- Name: monthly_active_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monthly_active_users (
    user_id text NOT NULL,
    "timestamp" bigint NOT NULL
);


--
-- Name: msc4242_state_dag_edges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msc4242_state_dag_edges (
    room_id text NOT NULL,
    event_id text NOT NULL,
    prev_state_event_id text
);


--
-- Name: msc4242_state_dag_forward_extremities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msc4242_state_dag_forward_extremities (
    room_id text NOT NULL,
    event_id text NOT NULL
);


--
-- Name: open_id_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.open_id_tokens (
    token text NOT NULL,
    ts_valid_until_ms bigint NOT NULL,
    user_id text NOT NULL
);


--
-- Name: partial_state_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partial_state_events (
    room_id text NOT NULL,
    event_id text NOT NULL
);


--
-- Name: partial_state_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partial_state_rooms (
    room_id text NOT NULL,
    device_lists_stream_id bigint DEFAULT 0 NOT NULL,
    join_event_id text,
    joined_via text
);


--
-- Name: partial_state_rooms_servers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partial_state_rooms_servers (
    room_id text NOT NULL,
    server_name text NOT NULL
);


--
-- Name: per_user_experimental_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.per_user_experimental_features (
    user_id text NOT NULL,
    feature text NOT NULL,
    enabled boolean DEFAULT false
);


--
-- Name: presence_stream; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.presence_stream (
    stream_id bigint,
    user_id text,
    state text,
    last_active_ts bigint,
    last_federation_update_ts bigint,
    last_user_sync_ts bigint,
    status_msg text,
    currently_active boolean,
    instance_name text
);


--
-- Name: presence_stream_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.presence_stream_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    user_id text NOT NULL,
    displayname text,
    avatar_url text,
    full_user_id text,
    fields jsonb,
    CONSTRAINT full_user_id_not_null CHECK ((full_user_id IS NOT NULL))
);


--
-- Name: push_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.push_rules (
    id bigint NOT NULL,
    user_name text NOT NULL,
    rule_id text NOT NULL,
    priority_class smallint NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    conditions text NOT NULL,
    actions text NOT NULL
);


--
-- Name: push_rules_enable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.push_rules_enable (
    id bigint NOT NULL,
    user_name text NOT NULL,
    rule_id text NOT NULL,
    enabled smallint
);


--
-- Name: push_rules_stream; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.push_rules_stream (
    stream_id bigint NOT NULL,
    event_stream_ordering bigint NOT NULL,
    user_id text NOT NULL,
    rule_id text NOT NULL,
    op text NOT NULL,
    priority_class smallint,
    priority integer,
    conditions text,
    actions text,
    instance_name text
);


--
-- Name: push_rules_stream_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.push_rules_stream_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pusher_throttle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pusher_throttle (
    pusher bigint NOT NULL,
    room_id text NOT NULL,
    last_sent_ts bigint,
    throttle_ms bigint
);


--
-- Name: pushers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pushers (
    id bigint NOT NULL,
    user_name text NOT NULL,
    access_token bigint,
    profile_tag text NOT NULL,
    kind text NOT NULL,
    app_id text NOT NULL,
    app_display_name text NOT NULL,
    device_display_name text NOT NULL,
    pushkey text NOT NULL,
    ts bigint NOT NULL,
    lang text,
    data text,
    last_stream_ordering bigint,
    last_success bigint,
    failing_since bigint,
    enabled boolean,
    device_id text,
    instance_name text
);


--
-- Name: pushers_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pushers_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quarantined_media_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quarantined_media_changes (
    stream_id integer NOT NULL,
    instance_name text NOT NULL,
    origin text,
    media_id text NOT NULL,
    quarantined boolean NOT NULL
);


--
-- Name: quarantined_media_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quarantined_media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ratelimit_override; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ratelimit_override (
    user_id text NOT NULL,
    messages_per_second bigint,
    burst_count bigint
);


--
-- Name: receipts_graph; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.receipts_graph (
    room_id text NOT NULL,
    receipt_type text NOT NULL,
    user_id text NOT NULL,
    event_ids text NOT NULL,
    data text NOT NULL,
    thread_id text
);


--
-- Name: receipts_linearized; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.receipts_linearized (
    stream_id bigint NOT NULL,
    room_id text NOT NULL,
    receipt_type text NOT NULL,
    user_id text NOT NULL,
    event_id text NOT NULL,
    data text NOT NULL,
    instance_name text,
    event_stream_ordering bigint,
    thread_id text
);


--
-- Name: receipts_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.receipts_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: received_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.received_transactions (
    transaction_id text,
    origin text,
    ts bigint,
    response_code integer,
    response_json bytea,
    has_been_referenced smallint DEFAULT 0
);


--
-- Name: redactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.redactions (
    event_id text NOT NULL,
    redacts text NOT NULL,
    have_censored boolean DEFAULT false NOT NULL,
    received_ts bigint,
    recheck boolean DEFAULT true NOT NULL
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_tokens (
    id bigint NOT NULL,
    user_id text NOT NULL,
    device_id text NOT NULL,
    token text NOT NULL,
    next_token_id bigint,
    expiry_ts bigint,
    ultimate_session_expiry_ts bigint
);


--
-- Name: registration_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration_tokens (
    token text NOT NULL,
    uses_allowed integer,
    pending integer NOT NULL,
    completed integer NOT NULL,
    expiry_time bigint
);


--
-- Name: rejections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rejections (
    event_id text NOT NULL,
    reason text NOT NULL,
    last_check text NOT NULL
);


--
-- Name: remote_media_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.remote_media_cache (
    media_origin text,
    media_id text,
    media_type text,
    created_ts bigint,
    upload_name text,
    media_length integer,
    filesystem_id text,
    last_access_ts bigint,
    quarantined_by text,
    authenticated boolean DEFAULT false NOT NULL,
    sha256 text
);


--
-- Name: remote_media_cache_thumbnails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.remote_media_cache_thumbnails (
    media_origin text,
    media_id text,
    thumbnail_width integer,
    thumbnail_height integer,
    thumbnail_method text,
    thumbnail_type text,
    thumbnail_length integer,
    filesystem_id text
);


--
-- Name: room_account_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_account_data (
    user_id text NOT NULL,
    room_id text NOT NULL,
    account_data_type text NOT NULL,
    stream_id bigint NOT NULL,
    content text NOT NULL,
    instance_name text
);


--
-- Name: room_alias_servers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_alias_servers (
    room_alias text NOT NULL,
    server text NOT NULL
);


--
-- Name: room_aliases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_aliases (
    room_alias text NOT NULL,
    room_id text NOT NULL,
    creator text
);


--
-- Name: room_ban_redactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_ban_redactions (
    room_id text NOT NULL,
    user_id text NOT NULL,
    redacting_event_id text NOT NULL,
    redact_end_ordering bigint
);


--
-- Name: room_depth; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_depth (
    room_id text NOT NULL,
    min_depth bigint
);


--
-- Name: room_forgetter_stream_pos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_forgetter_stream_pos (
    lock character(1) DEFAULT 'X'::bpchar NOT NULL,
    stream_id bigint NOT NULL,
    CONSTRAINT room_forgetter_stream_pos_lock_check CHECK ((lock = 'X'::bpchar))
);


--
-- Name: room_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_memberships (
    event_id text NOT NULL,
    user_id text NOT NULL,
    sender text NOT NULL,
    room_id text NOT NULL,
    membership text NOT NULL,
    forgotten integer DEFAULT 0,
    display_name text,
    avatar_url text,
    event_stream_ordering bigint,
    participant boolean DEFAULT false
);


--
-- Name: room_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_reports (
    id bigint NOT NULL,
    received_ts bigint NOT NULL,
    room_id text NOT NULL,
    user_id text NOT NULL,
    reason text NOT NULL
);


--
-- Name: room_retention; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_retention (
    room_id text NOT NULL,
    event_id text NOT NULL,
    min_lifetime bigint,
    max_lifetime bigint
);


--
-- Name: room_stats_current; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_stats_current (
    room_id text NOT NULL,
    current_state_events integer NOT NULL,
    joined_members integer NOT NULL,
    invited_members integer NOT NULL,
    left_members integer NOT NULL,
    banned_members integer NOT NULL,
    local_users_in_room integer NOT NULL,
    completed_delta_stream_id bigint NOT NULL,
    knocked_members integer
);


--
-- Name: room_stats_earliest_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_stats_earliest_token (
    room_id text NOT NULL,
    token bigint NOT NULL
);


--
-- Name: room_stats_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_stats_state (
    room_id text NOT NULL,
    name text,
    canonical_alias text,
    join_rules text,
    history_visibility text,
    encryption text,
    avatar text,
    guest_access text,
    is_federatable boolean,
    topic text,
    room_type text
);


--
-- Name: room_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_tags (
    user_id text NOT NULL,
    room_id text NOT NULL,
    tag text NOT NULL,
    content text NOT NULL
);


--
-- Name: room_tags_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_tags_revisions (
    user_id text NOT NULL,
    room_id text NOT NULL,
    stream_id bigint NOT NULL,
    instance_name text
);


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rooms (
    room_id text NOT NULL,
    is_public boolean,
    creator text,
    room_version text,
    has_auth_chain_index boolean
);


--
-- Name: scheduled_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduled_tasks (
    id text NOT NULL,
    action text NOT NULL,
    status text NOT NULL,
    "timestamp" bigint NOT NULL,
    resource_id text,
    params text,
    result text,
    error text
);


--
-- Name: schema_compat_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_compat_version (
    lock character(1) DEFAULT 'X'::bpchar NOT NULL,
    compat_version integer NOT NULL,
    CONSTRAINT schema_compat_version_lock_check CHECK ((lock = 'X'::bpchar))
);


--
-- Name: schema_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_version (
    lock character(1) DEFAULT 'X'::bpchar NOT NULL,
    version integer NOT NULL,
    upgraded boolean NOT NULL,
    CONSTRAINT schema_version_lock_check CHECK ((lock = 'X'::bpchar))
);


--
-- Name: server_keys_json; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.server_keys_json (
    server_name text NOT NULL,
    key_id text NOT NULL,
    from_server text NOT NULL,
    ts_added_ms bigint NOT NULL,
    ts_valid_until_ms bigint NOT NULL,
    key_json bytea NOT NULL
);


--
-- Name: server_signature_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.server_signature_keys (
    server_name text,
    key_id text,
    from_server text,
    ts_added_ms bigint,
    verify_key bytea,
    ts_valid_until_ms bigint
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    session_type text NOT NULL,
    session_id text NOT NULL,
    value text NOT NULL,
    expiry_time_ms bigint NOT NULL
);


--
-- Name: sliding_sync_connection_lazy_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sliding_sync_connection_lazy_members (
    connection_key bigint NOT NULL,
    connection_position bigint,
    room_id text NOT NULL,
    user_id text NOT NULL,
    last_seen_ts bigint NOT NULL
);


--
-- Name: sliding_sync_connection_positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sliding_sync_connection_positions (
    connection_position bigint NOT NULL,
    connection_key bigint NOT NULL,
    created_ts bigint NOT NULL
);


--
-- Name: sliding_sync_connection_positions_connection_position_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sliding_sync_connection_positions ALTER COLUMN connection_position ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sliding_sync_connection_positions_connection_position_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sliding_sync_connection_required_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sliding_sync_connection_required_state (
    required_state_id bigint NOT NULL,
    connection_key bigint NOT NULL,
    required_state text NOT NULL
);


--
-- Name: sliding_sync_connection_required_state_required_state_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sliding_sync_connection_required_state ALTER COLUMN required_state_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sliding_sync_connection_required_state_required_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sliding_sync_connection_room_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sliding_sync_connection_room_configs (
    connection_position bigint NOT NULL,
    room_id text NOT NULL,
    timeline_limit bigint NOT NULL,
    required_state_id bigint NOT NULL
);


--
-- Name: sliding_sync_connection_streams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sliding_sync_connection_streams (
    connection_position bigint NOT NULL,
    stream text NOT NULL,
    room_id text NOT NULL,
    room_status text NOT NULL,
    last_token text
);


--
-- Name: sliding_sync_connections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sliding_sync_connections (
    connection_key bigint NOT NULL,
    user_id text NOT NULL,
    effective_device_id text NOT NULL,
    conn_id text NOT NULL,
    created_ts bigint NOT NULL,
    last_used_ts bigint
);


--
-- Name: sliding_sync_connections_connection_key_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sliding_sync_connections ALTER COLUMN connection_key ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sliding_sync_connections_connection_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sliding_sync_joined_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sliding_sync_joined_rooms (
    room_id text NOT NULL,
    event_stream_ordering bigint NOT NULL,
    bump_stamp bigint,
    room_type text,
    room_name text,
    is_encrypted boolean DEFAULT false NOT NULL,
    tombstone_successor_room_id text
);


--
-- Name: sliding_sync_joined_rooms_to_recalculate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sliding_sync_joined_rooms_to_recalculate (
    room_id text NOT NULL
);


--
-- Name: sliding_sync_membership_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sliding_sync_membership_snapshots (
    room_id text NOT NULL,
    user_id text NOT NULL,
    sender text NOT NULL,
    membership_event_id text NOT NULL,
    membership text NOT NULL,
    forgotten integer DEFAULT 0 NOT NULL,
    event_stream_ordering bigint NOT NULL,
    event_instance_name text NOT NULL,
    has_known_state boolean DEFAULT false NOT NULL,
    room_type text,
    room_name text,
    is_encrypted boolean DEFAULT false NOT NULL,
    tombstone_successor_room_id text
);


--
-- Name: state_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.state_events (
    event_id text NOT NULL,
    room_id text NOT NULL,
    type text NOT NULL,
    state_key text NOT NULL,
    prev_state text
);


--
-- Name: state_group_edges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.state_group_edges (
    state_group bigint NOT NULL,
    prev_state_group bigint NOT NULL
);


--
-- Name: state_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.state_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: state_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.state_groups (
    id bigint NOT NULL,
    room_id text NOT NULL,
    event_id text NOT NULL
);


--
-- Name: state_groups_pending_deletion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.state_groups_pending_deletion (
    sequence_number bigint NOT NULL,
    state_group bigint NOT NULL,
    insertion_ts bigint NOT NULL
);


--
-- Name: state_groups_pending_deletion_sequence_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.state_groups_pending_deletion ALTER COLUMN sequence_number ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.state_groups_pending_deletion_sequence_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: state_groups_persisting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.state_groups_persisting (
    state_group bigint NOT NULL,
    instance_name text NOT NULL
);


--
-- Name: state_groups_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.state_groups_state (
    state_group bigint NOT NULL,
    room_id text NOT NULL,
    type text NOT NULL,
    state_key text NOT NULL,
    event_id text NOT NULL
);
ALTER TABLE ONLY public.state_groups_state ALTER COLUMN state_group SET (n_distinct=-0.02);


--
-- Name: stats_incremental_position; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stats_incremental_position (
    lock character(1) DEFAULT 'X'::bpchar NOT NULL,
    stream_id bigint NOT NULL,
    CONSTRAINT stats_incremental_position_lock_check CHECK ((lock = 'X'::bpchar))
);


--
-- Name: sticky_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sticky_events (
    stream_id integer NOT NULL,
    instance_name text NOT NULL,
    event_id text NOT NULL,
    room_id text NOT NULL,
    event_stream_ordering integer NOT NULL,
    sender text NOT NULL,
    expires_at bigint NOT NULL
);


--
-- Name: sticky_events_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sticky_events_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stream_ordering_to_exterm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stream_ordering_to_exterm (
    stream_ordering bigint NOT NULL,
    room_id text NOT NULL,
    event_id text NOT NULL
);


--
-- Name: stream_positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stream_positions (
    stream_name text NOT NULL,
    instance_name text NOT NULL,
    stream_id bigint NOT NULL
);


--
-- Name: thread_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thread_subscriptions (
    stream_id integer NOT NULL,
    instance_name text NOT NULL,
    room_id text NOT NULL,
    event_id text NOT NULL,
    user_id text NOT NULL,
    subscribed boolean NOT NULL,
    automatic boolean NOT NULL,
    unsubscribed_at_stream_ordering bigint,
    unsubscribed_at_topological_ordering bigint
);


--
-- Name: TABLE thread_subscriptions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.thread_subscriptions IS 'Tracks local users that subscribe to threads';


--
-- Name: COLUMN thread_subscriptions.subscribed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.thread_subscriptions.subscribed IS 'Whether the user is subscribed to the thread or not. We track unsubscribed threads because we need to stream the subscription change to the client.';


--
-- Name: COLUMN thread_subscriptions.automatic; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.thread_subscriptions.automatic IS 'True if the user was subscribed to the thread automatically by their client, or false if the client manually requested the subscription.';


--
-- Name: COLUMN thread_subscriptions.unsubscribed_at_stream_ordering; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.thread_subscriptions.unsubscribed_at_stream_ordering IS 'The maximum stream_ordering in the room when the unsubscription was made.';


--
-- Name: COLUMN thread_subscriptions.unsubscribed_at_topological_ordering; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.thread_subscriptions.unsubscribed_at_topological_ordering IS 'The maximum topological_ordering in the room when the unsubscription was made.';


--
-- Name: thread_subscriptions_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thread_subscriptions_sequence
    START WITH 2
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: threads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.threads (
    room_id text NOT NULL,
    thread_id text NOT NULL,
    latest_event_id text NOT NULL,
    topological_ordering bigint NOT NULL,
    stream_ordering bigint NOT NULL
);


--
-- Name: COLUMN threads.latest_event_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.threads.latest_event_id IS 'the ID of the event that is latest, ordered by (topological_ordering, stream_ordering)';


--
-- Name: COLUMN threads.topological_ordering; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.threads.topological_ordering IS 'the topological ordering of the thread''''s LATEST event.
Used as the primary way of ordering threads by recency in a room.';


--
-- Name: COLUMN threads.stream_ordering; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.threads.stream_ordering IS 'the stream ordering of the thread''s LATEST event.
Used as a tie-breaker for ordering threads by recency in a room, when the topological order is a tie.
Also used for recency ordering in sliding sync.';


--
-- Name: threepid_guest_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.threepid_guest_access_tokens (
    medium text,
    address text,
    guest_access_token text,
    first_inviter text
);


--
-- Name: threepid_validation_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.threepid_validation_session (
    session_id text NOT NULL,
    medium text NOT NULL,
    address text NOT NULL,
    client_secret text NOT NULL,
    last_send_attempt bigint NOT NULL,
    validated_at bigint
);


--
-- Name: threepid_validation_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.threepid_validation_token (
    token text NOT NULL,
    session_id text NOT NULL,
    next_link text,
    expires bigint NOT NULL
);


--
-- Name: timeline_gaps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timeline_gaps (
    room_id text NOT NULL,
    instance_name text NOT NULL,
    stream_ordering bigint NOT NULL
);


--
-- Name: ui_auth_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ui_auth_sessions (
    session_id text NOT NULL,
    creation_time bigint NOT NULL,
    serverdict text NOT NULL,
    clientdict text NOT NULL,
    uri text NOT NULL,
    method text NOT NULL,
    description text NOT NULL
);


--
-- Name: ui_auth_sessions_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ui_auth_sessions_credentials (
    session_id text NOT NULL,
    stage_type text NOT NULL,
    result text NOT NULL
);


--
-- Name: ui_auth_sessions_ips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ui_auth_sessions_ips (
    session_id text NOT NULL,
    ip text NOT NULL,
    user_agent text NOT NULL
);


--
-- Name: un_partial_stated_event_stream; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.un_partial_stated_event_stream (
    stream_id bigint NOT NULL,
    instance_name text NOT NULL,
    event_id text NOT NULL,
    rejection_status_changed boolean NOT NULL
);


--
-- Name: un_partial_stated_event_stream_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.un_partial_stated_event_stream_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: un_partial_stated_room_stream; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.un_partial_stated_room_stream (
    stream_id bigint NOT NULL,
    instance_name text NOT NULL,
    room_id text NOT NULL
);


--
-- Name: un_partial_stated_room_stream_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.un_partial_stated_room_stream_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_daily_visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_daily_visits (
    user_id text NOT NULL,
    device_id text,
    "timestamp" bigint NOT NULL,
    user_agent text
);


--
-- Name: user_directory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_directory (
    user_id text NOT NULL,
    room_id text,
    display_name text,
    avatar_url text
);


--
-- Name: user_directory_search; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_directory_search (
    user_id text NOT NULL,
    vector tsvector
);


--
-- Name: user_directory_stale_remote_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_directory_stale_remote_users (
    user_id text NOT NULL,
    user_server_name text NOT NULL,
    next_try_at_ts bigint NOT NULL,
    retry_counter integer NOT NULL
);


--
-- Name: user_directory_stream_pos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_directory_stream_pos (
    lock character(1) DEFAULT 'X'::bpchar NOT NULL,
    stream_id bigint,
    CONSTRAINT user_directory_stream_pos_lock_check CHECK ((lock = 'X'::bpchar))
);


--
-- Name: user_external_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_external_ids (
    auth_provider text NOT NULL,
    external_id text NOT NULL,
    user_id text NOT NULL
);


--
-- Name: user_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_filters (
    user_id text NOT NULL,
    filter_id bigint NOT NULL,
    filter_json bytea NOT NULL,
    full_user_id text,
    CONSTRAINT full_user_id_not_null CHECK ((full_user_id IS NOT NULL))
);


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
-- Name: user_ips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_ips (
    user_id text NOT NULL,
    access_token text NOT NULL,
    device_id text,
    ip text NOT NULL,
    user_agent text NOT NULL,
    last_seen bigint NOT NULL
);


--
-- Name: user_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_reports (
    id bigint NOT NULL,
    received_ts bigint NOT NULL,
    target_user_id text NOT NULL,
    user_id text NOT NULL,
    reason text NOT NULL
);


--
-- Name: user_signature_stream; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_signature_stream (
    stream_id bigint NOT NULL,
    from_user_id text NOT NULL,
    user_ids text NOT NULL,
    instance_name text
);


--
-- Name: user_stats_current; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_stats_current (
    user_id text NOT NULL,
    joined_rooms bigint NOT NULL,
    completed_delta_stream_id bigint NOT NULL
);


--
-- Name: user_threepid_id_server; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_threepid_id_server (
    user_id text NOT NULL,
    medium text NOT NULL,
    address text NOT NULL,
    id_server text NOT NULL
);


--
-- Name: user_threepids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_threepids (
    user_id text NOT NULL,
    medium text NOT NULL,
    address text NOT NULL,
    validated_at bigint NOT NULL,
    added_at bigint NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    name text,
    password_hash text,
    creation_ts bigint,
    admin smallint DEFAULT 0 NOT NULL,
    upgrade_ts bigint,
    is_guest smallint DEFAULT 0 NOT NULL,
    appservice_id text,
    consent_version text,
    consent_server_notice_sent text,
    user_type text,
    deactivated smallint DEFAULT 0 NOT NULL,
    shadow_banned boolean,
    consent_ts bigint,
    approved boolean,
    locked boolean DEFAULT false NOT NULL,
    suspended boolean DEFAULT false NOT NULL
);


--
-- Name: users_in_public_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_in_public_rooms (
    user_id text NOT NULL,
    room_id text NOT NULL
);


--
-- Name: users_pending_deactivation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_pending_deactivation (
    user_id text NOT NULL
);


--
-- Name: users_to_send_full_presence_to; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_to_send_full_presence_to (
    user_id text NOT NULL,
    presence_stream_id bigint
);


--
-- Name: users_who_share_private_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_who_share_private_rooms (
    user_id text NOT NULL,
    other_user_id text NOT NULL,
    room_id text NOT NULL
);


--
-- Name: worker_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker_locks (
    lock_name text NOT NULL,
    lock_key text NOT NULL,
    instance_name text NOT NULL,
    token text NOT NULL,
    last_renewed_ts bigint NOT NULL
);


--
-- Name: worker_read_write_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.worker_read_write_locks (
    lock_name text NOT NULL,
    lock_key text NOT NULL,
    instance_name text NOT NULL,
    write_lock boolean NOT NULL,
    token text NOT NULL,
    last_renewed_ts bigint NOT NULL
);


--
-- Name: worker_read_write_locks_mode; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.worker_read_write_locks_mode (
    lock_name text NOT NULL,
    lock_key text NOT NULL,
    write_lock boolean NOT NULL,
    token text NOT NULL
);


--
-- Name: instance_map instance_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance_map ALTER COLUMN instance_id SET DEFAULT nextval('public.instance_map_instance_id_seq'::regclass);


--
-- Name: access_tokens access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (id);


--
-- Name: access_tokens access_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_token_key UNIQUE (token);


--
-- Name: account_data account_data_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_data
    ADD CONSTRAINT account_data_uniqueness UNIQUE (user_id, account_data_type);


--
-- Name: account_validity account_validity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_validity
    ADD CONSTRAINT account_validity_pkey PRIMARY KEY (user_id);


--
-- Name: application_services_state application_services_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_services_state
    ADD CONSTRAINT application_services_state_pkey PRIMARY KEY (as_id);


--
-- Name: application_services_txns application_services_txns_as_id_txn_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_services_txns
    ADD CONSTRAINT application_services_txns_as_id_txn_id_key UNIQUE (as_id, txn_id);


--
-- Name: applied_module_schemas applied_module_schemas_module_name_file_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applied_module_schemas
    ADD CONSTRAINT applied_module_schemas_module_name_file_key UNIQUE (module_name, file);


--
-- Name: applied_schema_deltas applied_schema_deltas_version_file_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applied_schema_deltas
    ADD CONSTRAINT applied_schema_deltas_version_file_key UNIQUE (version, file);


--
-- Name: appservice_stream_position appservice_stream_position_lock_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appservice_stream_position
    ADD CONSTRAINT appservice_stream_position_lock_key UNIQUE (lock);


--
-- Name: background_updates background_updates_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_updates
    ADD CONSTRAINT background_updates_uniqueness UNIQUE (update_name);


--
-- Name: current_state_events current_state_events_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.current_state_events
    ADD CONSTRAINT current_state_events_event_id_key UNIQUE (event_id);


--
-- Name: current_state_events current_state_events_room_id_type_state_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.current_state_events
    ADD CONSTRAINT current_state_events_room_id_type_state_key_key UNIQUE (room_id, type, state_key);


--
-- Name: dehydrated_devices dehydrated_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dehydrated_devices
    ADD CONSTRAINT dehydrated_devices_pkey PRIMARY KEY (user_id);


--
-- Name: delayed_events delayed_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_events
    ADD CONSTRAINT delayed_events_pkey PRIMARY KEY (user_localpart, delay_id);


--
-- Name: delayed_events_stream_pos delayed_events_stream_pos_lock_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_events_stream_pos
    ADD CONSTRAINT delayed_events_stream_pos_lock_key UNIQUE (lock);


--
-- Name: destination_rooms destination_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destination_rooms
    ADD CONSTRAINT destination_rooms_pkey PRIMARY KEY (destination, room_id);


--
-- Name: destinations destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_pkey PRIMARY KEY (destination);


--
-- Name: device_lists_changes_converted_stream_position device_lists_changes_converted_stream_position_lock_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_lists_changes_converted_stream_position
    ADD CONSTRAINT device_lists_changes_converted_stream_position_lock_key UNIQUE (lock);


--
-- Name: device_lists_changes_in_room_max_pruned_stream_id device_lists_changes_in_room_max_pruned_stream_id_lock_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_lists_changes_in_room_max_pruned_stream_id
    ADD CONSTRAINT device_lists_changes_in_room_max_pruned_stream_id_lock_key UNIQUE (lock);


--
-- Name: device_lists_remote_pending device_lists_remote_pending_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_lists_remote_pending
    ADD CONSTRAINT device_lists_remote_pending_pkey PRIMARY KEY (stream_id);


--
-- Name: devices device_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT device_uniqueness UNIQUE (user_id, device_id);


--
-- Name: e2e_device_keys_json e2e_device_keys_json_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e2e_device_keys_json
    ADD CONSTRAINT e2e_device_keys_json_uniqueness UNIQUE (user_id, device_id);


--
-- Name: e2e_fallback_keys_json e2e_fallback_keys_json_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e2e_fallback_keys_json
    ADD CONSTRAINT e2e_fallback_keys_json_uniqueness UNIQUE (user_id, device_id, algorithm);


--
-- Name: e2e_one_time_keys_json e2e_one_time_keys_json_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e2e_one_time_keys_json
    ADD CONSTRAINT e2e_one_time_keys_json_uniqueness UNIQUE (user_id, device_id, algorithm, key_id);


--
-- Name: event_auth_chain_to_calculate event_auth_chain_to_calculate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_auth_chain_to_calculate
    ADD CONSTRAINT event_auth_chain_to_calculate_pkey PRIMARY KEY (event_id);


--
-- Name: event_auth_chains event_auth_chains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_auth_chains
    ADD CONSTRAINT event_auth_chains_pkey PRIMARY KEY (event_id);


--
-- Name: event_backward_extremities event_backward_extremities_event_id_room_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_backward_extremities
    ADD CONSTRAINT event_backward_extremities_event_id_room_id_key UNIQUE (event_id, room_id);


--
-- Name: event_expiry event_expiry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_expiry
    ADD CONSTRAINT event_expiry_pkey PRIMARY KEY (event_id);


--
-- Name: event_failed_pull_attempts event_failed_pull_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_failed_pull_attempts
    ADD CONSTRAINT event_failed_pull_attempts_pkey PRIMARY KEY (room_id, event_id);


--
-- Name: event_forward_extremities event_forward_extremities_event_id_room_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_forward_extremities
    ADD CONSTRAINT event_forward_extremities_event_id_room_id_key UNIQUE (event_id, room_id);


--
-- Name: event_push_actions event_id_user_id_profile_tag_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_push_actions
    ADD CONSTRAINT event_id_user_id_profile_tag_uniqueness UNIQUE (room_id, event_id, user_id, profile_tag);


--
-- Name: event_json event_json_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_json
    ADD CONSTRAINT event_json_event_id_key UNIQUE (event_id);


--
-- Name: event_labels event_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_labels
    ADD CONSTRAINT event_labels_pkey PRIMARY KEY (event_id, label);


--
-- Name: event_push_summary_last_receipt_stream_id event_push_summary_last_receipt_stream_id_lock_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_push_summary_last_receipt_stream_id
    ADD CONSTRAINT event_push_summary_last_receipt_stream_id_lock_key UNIQUE (lock);


--
-- Name: event_push_summary_stream_ordering event_push_summary_stream_ordering_lock_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_push_summary_stream_ordering
    ADD CONSTRAINT event_push_summary_stream_ordering_lock_key UNIQUE (lock);


--
-- Name: event_push_summary event_push_summary_thread_id; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.event_push_summary
    ADD CONSTRAINT event_push_summary_thread_id CHECK ((thread_id IS NOT NULL)) NOT VALID;


--
-- Name: event_reports event_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_reports
    ADD CONSTRAINT event_reports_pkey PRIMARY KEY (id);


--
-- Name: event_to_state_groups event_to_state_groups_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_to_state_groups
    ADD CONSTRAINT event_to_state_groups_event_id_key UNIQUE (event_id);


--
-- Name: events events_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_event_id_key UNIQUE (event_id);


--
-- Name: ex_outlier_stream ex_outlier_stream_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ex_outlier_stream
    ADD CONSTRAINT ex_outlier_stream_pkey PRIMARY KEY (event_stream_ordering);


--
-- Name: instance_map instance_map_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance_map
    ADD CONSTRAINT instance_map_pkey PRIMARY KEY (instance_id);


--
-- Name: local_media_repository local_media_repository_media_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_media_repository
    ADD CONSTRAINT local_media_repository_media_id_key UNIQUE (media_id);


--
-- Name: login_tokens login_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_tokens
    ADD CONSTRAINT login_tokens_pkey PRIMARY KEY (token);


--
-- Name: user_threepids medium_address; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_threepids
    ADD CONSTRAINT medium_address UNIQUE (medium, address);


--
-- Name: msc4242_state_dag_forward_extremities msc4242_state_dag_forward_extremities_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msc4242_state_dag_forward_extremities
    ADD CONSTRAINT msc4242_state_dag_forward_extremities_event_id_key UNIQUE (event_id);


--
-- Name: open_id_tokens open_id_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.open_id_tokens
    ADD CONSTRAINT open_id_tokens_pkey PRIMARY KEY (token);


--
-- Name: partial_state_events partial_state_events_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partial_state_events
    ADD CONSTRAINT partial_state_events_event_id_key UNIQUE (event_id);


--
-- Name: partial_state_rooms partial_state_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partial_state_rooms
    ADD CONSTRAINT partial_state_rooms_pkey PRIMARY KEY (room_id);


--
-- Name: partial_state_rooms_servers partial_state_rooms_servers_room_id_server_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partial_state_rooms_servers
    ADD CONSTRAINT partial_state_rooms_servers_room_id_server_name_key UNIQUE (room_id, server_name);


--
-- Name: per_user_experimental_features per_user_experimental_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.per_user_experimental_features
    ADD CONSTRAINT per_user_experimental_features_pkey PRIMARY KEY (user_id, feature);


--
-- Name: profiles profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_key UNIQUE (user_id);


--
-- Name: push_rules_enable push_rules_enable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_rules_enable
    ADD CONSTRAINT push_rules_enable_pkey PRIMARY KEY (id);


--
-- Name: push_rules_enable push_rules_enable_user_name_rule_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_rules_enable
    ADD CONSTRAINT push_rules_enable_user_name_rule_id_key UNIQUE (user_name, rule_id);


--
-- Name: push_rules push_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_rules
    ADD CONSTRAINT push_rules_pkey PRIMARY KEY (id);


--
-- Name: push_rules push_rules_user_name_rule_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_rules
    ADD CONSTRAINT push_rules_user_name_rule_id_key UNIQUE (user_name, rule_id);


--
-- Name: pusher_throttle pusher_throttle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pusher_throttle
    ADD CONSTRAINT pusher_throttle_pkey PRIMARY KEY (pusher, room_id);


--
-- Name: pushers pushers2_app_id_pushkey_user_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pushers
    ADD CONSTRAINT pushers2_app_id_pushkey_user_name_key UNIQUE (app_id, pushkey, user_name);


--
-- Name: pushers pushers2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pushers
    ADD CONSTRAINT pushers2_pkey PRIMARY KEY (id);


--
-- Name: quarantined_media_changes quarantined_media_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quarantined_media_changes
    ADD CONSTRAINT quarantined_media_changes_pkey PRIMARY KEY (stream_id);


--
-- Name: receipts_graph receipts_graph_uniqueness_thread; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipts_graph
    ADD CONSTRAINT receipts_graph_uniqueness_thread UNIQUE (room_id, receipt_type, user_id, thread_id);


--
-- Name: receipts_linearized receipts_linearized_uniqueness_thread; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipts_linearized
    ADD CONSTRAINT receipts_linearized_uniqueness_thread UNIQUE (room_id, receipt_type, user_id, thread_id);


--
-- Name: received_transactions received_transactions_transaction_id_origin_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.received_transactions
    ADD CONSTRAINT received_transactions_transaction_id_origin_key UNIQUE (transaction_id, origin);


--
-- Name: redactions redactions_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.redactions
    ADD CONSTRAINT redactions_event_id_key UNIQUE (event_id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_key UNIQUE (token);


--
-- Name: registration_tokens registration_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_tokens
    ADD CONSTRAINT registration_tokens_token_key UNIQUE (token);


--
-- Name: rejections rejections_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rejections
    ADD CONSTRAINT rejections_event_id_key UNIQUE (event_id);


--
-- Name: remote_media_cache remote_media_cache_media_origin_media_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remote_media_cache
    ADD CONSTRAINT remote_media_cache_media_origin_media_id_key UNIQUE (media_origin, media_id);


--
-- Name: room_account_data room_account_data_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_account_data
    ADD CONSTRAINT room_account_data_uniqueness UNIQUE (user_id, room_id, account_data_type);


--
-- Name: room_aliases room_aliases_room_alias_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_aliases
    ADD CONSTRAINT room_aliases_room_alias_key UNIQUE (room_alias);


--
-- Name: room_ban_redactions room_ban_redaction_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_ban_redactions
    ADD CONSTRAINT room_ban_redaction_uniqueness UNIQUE (room_id, user_id);


--
-- Name: room_depth room_depth_room_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_depth
    ADD CONSTRAINT room_depth_room_id_key UNIQUE (room_id);


--
-- Name: room_forgetter_stream_pos room_forgetter_stream_pos_lock_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_forgetter_stream_pos
    ADD CONSTRAINT room_forgetter_stream_pos_lock_key UNIQUE (lock);


--
-- Name: room_memberships room_memberships_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_memberships
    ADD CONSTRAINT room_memberships_event_id_key UNIQUE (event_id);


--
-- Name: room_reports room_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_reports
    ADD CONSTRAINT room_reports_pkey PRIMARY KEY (id);


--
-- Name: room_retention room_retention_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_retention
    ADD CONSTRAINT room_retention_pkey PRIMARY KEY (room_id, event_id);


--
-- Name: room_stats_current room_stats_current_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_stats_current
    ADD CONSTRAINT room_stats_current_pkey PRIMARY KEY (room_id);


--
-- Name: room_tags_revisions room_tag_revisions_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_tags_revisions
    ADD CONSTRAINT room_tag_revisions_uniqueness UNIQUE (user_id, room_id);


--
-- Name: room_tags room_tag_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_tags
    ADD CONSTRAINT room_tag_uniqueness UNIQUE (user_id, room_id, tag);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (room_id);


--
-- Name: scheduled_tasks scheduled_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_tasks
    ADD CONSTRAINT scheduled_tasks_pkey PRIMARY KEY (id);


--
-- Name: schema_compat_version schema_compat_version_lock_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_compat_version
    ADD CONSTRAINT schema_compat_version_lock_key UNIQUE (lock);


--
-- Name: schema_version schema_version_lock_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_version
    ADD CONSTRAINT schema_version_lock_key UNIQUE (lock);


--
-- Name: server_keys_json server_keys_json_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.server_keys_json
    ADD CONSTRAINT server_keys_json_uniqueness UNIQUE (server_name, key_id, from_server);


--
-- Name: server_signature_keys server_signature_keys_server_name_key_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.server_signature_keys
    ADD CONSTRAINT server_signature_keys_server_name_key_id_key UNIQUE (server_name, key_id);


--
-- Name: sessions sessions_session_type_session_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_session_type_session_id_key UNIQUE (session_type, session_id);


--
-- Name: sliding_sync_connection_positions sliding_sync_connection_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_connection_positions
    ADD CONSTRAINT sliding_sync_connection_positions_pkey PRIMARY KEY (connection_position);


--
-- Name: sliding_sync_connection_required_state sliding_sync_connection_required_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_connection_required_state
    ADD CONSTRAINT sliding_sync_connection_required_state_pkey PRIMARY KEY (required_state_id);


--
-- Name: sliding_sync_connections sliding_sync_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_connections
    ADD CONSTRAINT sliding_sync_connections_pkey PRIMARY KEY (connection_key);


--
-- Name: sliding_sync_joined_rooms sliding_sync_joined_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_joined_rooms
    ADD CONSTRAINT sliding_sync_joined_rooms_pkey PRIMARY KEY (room_id);


--
-- Name: sliding_sync_joined_rooms_to_recalculate sliding_sync_joined_rooms_to_recalculate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_joined_rooms_to_recalculate
    ADD CONSTRAINT sliding_sync_joined_rooms_to_recalculate_pkey PRIMARY KEY (room_id);


--
-- Name: sliding_sync_membership_snapshots sliding_sync_membership_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_membership_snapshots
    ADD CONSTRAINT sliding_sync_membership_snapshots_pkey PRIMARY KEY (room_id, user_id);


--
-- Name: state_events state_events_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_events
    ADD CONSTRAINT state_events_event_id_key UNIQUE (event_id);


--
-- Name: state_groups_pending_deletion state_groups_pending_deletion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_groups_pending_deletion
    ADD CONSTRAINT state_groups_pending_deletion_pkey PRIMARY KEY (sequence_number);


--
-- Name: state_groups_persisting state_groups_persisting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_groups_persisting
    ADD CONSTRAINT state_groups_persisting_pkey PRIMARY KEY (state_group, instance_name);


--
-- Name: state_groups state_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_groups
    ADD CONSTRAINT state_groups_pkey PRIMARY KEY (id);


--
-- Name: stats_incremental_position stats_incremental_position_lock_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stats_incremental_position
    ADD CONSTRAINT stats_incremental_position_lock_key UNIQUE (lock);


--
-- Name: sticky_events sticky_events_event_stream_ordering_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sticky_events
    ADD CONSTRAINT sticky_events_event_stream_ordering_key UNIQUE (event_stream_ordering);


--
-- Name: sticky_events sticky_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sticky_events
    ADD CONSTRAINT sticky_events_pkey PRIMARY KEY (stream_id);


--
-- Name: thread_subscriptions thread_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thread_subscriptions
    ADD CONSTRAINT thread_subscriptions_pkey PRIMARY KEY (stream_id);


--
-- Name: thread_subscriptions thread_subscriptions_room_id_event_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thread_subscriptions
    ADD CONSTRAINT thread_subscriptions_room_id_event_id_user_id_key UNIQUE (room_id, event_id, user_id);


--
-- Name: threads threads_uniqueness; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.threads
    ADD CONSTRAINT threads_uniqueness UNIQUE (room_id, thread_id);


--
-- Name: threepid_validation_session threepid_validation_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.threepid_validation_session
    ADD CONSTRAINT threepid_validation_session_pkey PRIMARY KEY (session_id);


--
-- Name: threepid_validation_token threepid_validation_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.threepid_validation_token
    ADD CONSTRAINT threepid_validation_token_pkey PRIMARY KEY (token);


--
-- Name: ui_auth_sessions_credentials ui_auth_sessions_credentials_session_id_stage_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ui_auth_sessions_credentials
    ADD CONSTRAINT ui_auth_sessions_credentials_session_id_stage_type_key UNIQUE (session_id, stage_type);


--
-- Name: ui_auth_sessions_ips ui_auth_sessions_ips_session_id_ip_user_agent_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ui_auth_sessions_ips
    ADD CONSTRAINT ui_auth_sessions_ips_session_id_ip_user_agent_key UNIQUE (session_id, ip, user_agent);


--
-- Name: ui_auth_sessions ui_auth_sessions_session_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ui_auth_sessions
    ADD CONSTRAINT ui_auth_sessions_session_id_key UNIQUE (session_id);


--
-- Name: un_partial_stated_event_stream un_partial_stated_event_stream_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.un_partial_stated_event_stream
    ADD CONSTRAINT un_partial_stated_event_stream_pkey PRIMARY KEY (stream_id);


--
-- Name: un_partial_stated_room_stream un_partial_stated_room_stream_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.un_partial_stated_room_stream
    ADD CONSTRAINT un_partial_stated_room_stream_pkey PRIMARY KEY (stream_id);


--
-- Name: user_directory_stale_remote_users user_directory_stale_remote_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_directory_stale_remote_users
    ADD CONSTRAINT user_directory_stale_remote_users_pkey PRIMARY KEY (user_id);


--
-- Name: user_directory_stream_pos user_directory_stream_pos_lock_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_directory_stream_pos
    ADD CONSTRAINT user_directory_stream_pos_lock_key UNIQUE (lock);


--
-- Name: user_external_ids user_external_ids_auth_provider_external_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_external_ids
    ADD CONSTRAINT user_external_ids_auth_provider_external_id_key UNIQUE (auth_provider, external_id);


--
-- Name: user_reports user_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_reports
    ADD CONSTRAINT user_reports_pkey PRIMARY KEY (id);


--
-- Name: user_stats_current user_stats_current_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_stats_current
    ADD CONSTRAINT user_stats_current_pkey PRIMARY KEY (user_id);


--
-- Name: users users_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_name_key UNIQUE (name);


--
-- Name: users_to_send_full_presence_to users_to_send_full_presence_to_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_to_send_full_presence_to
    ADD CONSTRAINT users_to_send_full_presence_to_pkey PRIMARY KEY (user_id);


--
-- Name: access_tokens_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX access_tokens_device_id ON public.access_tokens USING btree (user_id, device_id);


--
-- Name: account_data_stream_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_data_stream_id ON public.account_data USING btree (user_id, stream_id);


--
-- Name: application_services_txns_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX application_services_txns_id ON public.application_services_txns USING btree (as_id);


--
-- Name: appservice_room_list_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX appservice_room_list_idx ON public.appservice_room_list USING btree (appservice_id, network_id, room_id);


--
-- Name: blocked_rooms_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX blocked_rooms_idx ON public.blocked_rooms USING btree (room_id);


--
-- Name: cache_invalidation_stream_by_instance_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cache_invalidation_stream_by_instance_id ON public.cache_invalidation_stream_by_instance USING btree (stream_id);


--
-- Name: cache_invalidation_stream_by_instance_instance_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_invalidation_stream_by_instance_instance_index ON public.cache_invalidation_stream_by_instance USING btree (instance_name, stream_id);


--
-- Name: current_state_delta_stream_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX current_state_delta_stream_idx ON public.current_state_delta_stream USING btree (stream_id);


--
-- Name: current_state_events_member_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX current_state_events_member_index ON public.current_state_events USING btree (state_key) WHERE (type = 'm.room.member'::text);


--
-- Name: delayed_events_is_processed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_events_is_processed ON public.delayed_events USING btree (is_processed);


--
-- Name: delayed_events_room_state_event_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_events_room_state_event_idx ON public.delayed_events USING btree (room_id, event_type, state_key) WHERE (state_key IS NOT NULL);


--
-- Name: delayed_events_send_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_events_send_ts ON public.delayed_events USING btree (send_ts);


--
-- Name: deleted_pushers_stream_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX deleted_pushers_stream_id ON public.deleted_pushers USING btree (stream_id);


--
-- Name: destination_rooms_room_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX destination_rooms_room_id ON public.destination_rooms USING btree (room_id);


--
-- Name: device_auth_providers_devices; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_auth_providers_devices ON public.device_auth_providers USING btree (user_id, device_id);


--
-- Name: device_auth_providers_sessions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_auth_providers_sessions ON public.device_auth_providers USING btree (auth_provider_id, auth_provider_session_id);


--
-- Name: device_federation_inbox_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_federation_inbox_sender_id ON public.device_federation_inbox USING btree (origin, message_id);


--
-- Name: device_federation_outbox_destination_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_federation_outbox_destination_id ON public.device_federation_outbox USING btree (destination, stream_id);


--
-- Name: device_federation_outbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_federation_outbox_id ON public.device_federation_outbox USING btree (stream_id);


--
-- Name: device_inbox_stream_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_inbox_stream_id_user_id ON public.device_inbox USING btree (stream_id, user_id);


--
-- Name: device_inbox_user_stream_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_inbox_user_stream_id ON public.device_inbox USING btree (user_id, device_id, stream_id);


--
-- Name: device_lists_changes_in_room_by_room_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_lists_changes_in_room_by_room_idx ON public.device_lists_changes_in_room USING btree (room_id, stream_id);


--
-- Name: device_lists_changes_in_stream_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX device_lists_changes_in_stream_id ON public.device_lists_changes_in_room USING btree (stream_id, room_id);


--
-- Name: device_lists_changes_in_stream_id_unconverted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_lists_changes_in_stream_id_unconverted ON public.device_lists_changes_in_room USING btree (stream_id) WHERE (NOT converted_to_destinations);


--
-- Name: device_lists_outbound_last_success_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX device_lists_outbound_last_success_unique_idx ON public.device_lists_outbound_last_success USING btree (destination, user_id);


--
-- Name: device_lists_outbound_pokes_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_lists_outbound_pokes_id ON public.device_lists_outbound_pokes USING btree (destination, stream_id);


--
-- Name: device_lists_outbound_pokes_stream; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_lists_outbound_pokes_stream ON public.device_lists_outbound_pokes USING btree (stream_id);


--
-- Name: device_lists_outbound_pokes_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_lists_outbound_pokes_user ON public.device_lists_outbound_pokes USING btree (destination, user_id);


--
-- Name: device_lists_remote_cache_unique_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX device_lists_remote_cache_unique_id ON public.device_lists_remote_cache USING btree (user_id, device_id);


--
-- Name: device_lists_remote_extremeties_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX device_lists_remote_extremeties_unique_idx ON public.device_lists_remote_extremeties USING btree (user_id);


--
-- Name: device_lists_remote_pending_user_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX device_lists_remote_pending_user_device_id ON public.device_lists_remote_pending USING btree (user_id, device_id);


--
-- Name: device_lists_remote_resync_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX device_lists_remote_resync_idx ON public.device_lists_remote_resync USING btree (user_id);


--
-- Name: device_lists_remote_resync_ts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_lists_remote_resync_ts_idx ON public.device_lists_remote_resync USING btree (added_ts);


--
-- Name: device_lists_stream_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_lists_stream_id ON public.device_lists_stream USING btree (stream_id, user_id);


--
-- Name: device_lists_stream_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX device_lists_stream_user_id ON public.device_lists_stream USING btree (user_id, device_id);


--
-- Name: e2e_cross_signing_keys_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX e2e_cross_signing_keys_idx ON public.e2e_cross_signing_keys USING btree (user_id, keytype, stream_id);


--
-- Name: e2e_cross_signing_keys_stream_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX e2e_cross_signing_keys_stream_idx ON public.e2e_cross_signing_keys USING btree (stream_id);


--
-- Name: e2e_cross_signing_signatures2_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX e2e_cross_signing_signatures2_idx ON public.e2e_cross_signing_signatures USING btree (user_id, target_user_id, target_device_id);


--
-- Name: e2e_room_keys_versions_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX e2e_room_keys_versions_idx ON public.e2e_room_keys_versions USING btree (user_id, version);


--
-- Name: e2e_room_keys_with_version_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX e2e_room_keys_with_version_idx ON public.e2e_room_keys USING btree (user_id, version, room_id, session_id);


--
-- Name: erased_users_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX erased_users_user ON public.erased_users USING btree (user_id);


--
-- Name: ev_b_extrem_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ev_b_extrem_id ON public.event_backward_extremities USING btree (event_id);


--
-- Name: ev_b_extrem_room; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ev_b_extrem_room ON public.event_backward_extremities USING btree (room_id);


--
-- Name: ev_edges_prev_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ev_edges_prev_id ON public.event_edges USING btree (prev_event_id);


--
-- Name: ev_extrem_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ev_extrem_id ON public.event_forward_extremities USING btree (event_id);


--
-- Name: ev_extrem_room; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ev_extrem_room ON public.event_forward_extremities USING btree (room_id);


--
-- Name: evauth_edges_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX evauth_edges_id ON public.event_auth USING btree (event_id);


--
-- Name: event_auth_chain_links_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_auth_chain_links_idx ON public.event_auth_chain_links USING btree (origin_chain_id, target_chain_id);


--
-- Name: event_auth_chain_to_calculate_rm_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_auth_chain_to_calculate_rm_id ON public.event_auth_chain_to_calculate USING btree (room_id);


--
-- Name: event_auth_chains_c_seq_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX event_auth_chains_c_seq_index ON public.event_auth_chains USING btree (chain_id, sequence_number);


--
-- Name: event_contains_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_contains_url_index ON public.events USING btree (room_id, topological_ordering, stream_ordering) WHERE ((contains_url = true) AND (outlier = false));


--
-- Name: event_edges_event_id_prev_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX event_edges_event_id_prev_event_id_idx ON public.event_edges USING btree (event_id, prev_event_id);


--
-- Name: event_expiry_expiry_ts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_expiry_expiry_ts_idx ON public.event_expiry USING btree (expiry_ts);


--
-- Name: event_failed_pull_attempts_room_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_failed_pull_attempts_room_id ON public.event_failed_pull_attempts USING btree (room_id);


--
-- Name: event_labels_room_id_label_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_labels_room_id_label_idx ON public.event_labels USING btree (room_id, label, topological_ordering);


--
-- Name: event_push_actions_highlights_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_push_actions_highlights_index ON public.event_push_actions USING btree (user_id, room_id, topological_ordering, stream_ordering) WHERE (highlight = 1);


--
-- Name: event_push_actions_rm_tokens; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_push_actions_rm_tokens ON public.event_push_actions USING btree (user_id, room_id, topological_ordering, stream_ordering);


--
-- Name: event_push_actions_room_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_push_actions_room_id_user_id ON public.event_push_actions USING btree (room_id, user_id);


--
-- Name: event_push_actions_staging_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_push_actions_staging_id ON public.event_push_actions_staging USING btree (event_id);


--
-- Name: event_push_actions_stream_highlight_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_push_actions_stream_highlight_index ON public.event_push_actions USING btree (highlight, stream_ordering) WHERE (highlight = 0);


--
-- Name: event_push_actions_stream_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_push_actions_stream_ordering ON public.event_push_actions USING btree (stream_ordering, user_id);


--
-- Name: event_push_actions_u_highlight; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_push_actions_u_highlight ON public.event_push_actions USING btree (user_id, stream_ordering);


--
-- Name: event_push_summary_unique_index2; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX event_push_summary_unique_index2 ON public.event_push_summary USING btree (user_id, room_id, thread_id);


--
-- Name: event_relations_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX event_relations_id ON public.event_relations USING btree (event_id);


--
-- Name: event_relations_relates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_relations_relates ON public.event_relations USING btree (relates_to_id, relation_type, aggregation_key);


--
-- Name: event_search_ev_ridx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_search_ev_ridx ON public.event_search USING btree (room_id);


--
-- Name: event_search_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX event_search_event_id_idx ON public.event_search USING btree (event_id);


--
-- Name: event_search_fts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_search_fts_idx ON public.event_search USING gin (vector);


--
-- Name: event_to_state_groups_sg_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_to_state_groups_sg_index ON public.event_to_state_groups USING btree (state_group);


--
-- Name: event_txn_id_device_id_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX event_txn_id_device_id_event_id ON public.event_txn_id_device_id USING btree (event_id);


--
-- Name: event_txn_id_device_id_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_txn_id_device_id_ts ON public.event_txn_id_device_id USING btree (inserted_ts);


--
-- Name: event_txn_id_device_id_txn_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX event_txn_id_device_id_txn_id ON public.event_txn_id_device_id USING btree (room_id, user_id, device_id, txn_id);


--
-- Name: events_jump_to_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_jump_to_date_idx ON public.events USING btree (room_id, origin_server_ts) WHERE (NOT outlier);


--
-- Name: events_order_room; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_order_room ON public.events USING btree (room_id, topological_ordering, stream_ordering);


--
-- Name: events_room_stream; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_room_stream ON public.events USING btree (room_id, stream_ordering);


--
-- Name: events_stream_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX events_stream_ordering ON public.events USING btree (stream_ordering);


--
-- Name: events_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_ts ON public.events USING btree (origin_server_ts, stream_ordering);


--
-- Name: federation_inbound_events_staging_instance_event; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX federation_inbound_events_staging_instance_event ON public.federation_inbound_events_staging USING btree (origin, event_id);


--
-- Name: federation_inbound_events_staging_room; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX federation_inbound_events_staging_room ON public.federation_inbound_events_staging USING btree (room_id, received_ts);


--
-- Name: federation_stream_position_instance; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX federation_stream_position_instance ON public.federation_stream_position USING btree (type, instance_name);


--
-- Name: full_users_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX full_users_unique_idx ON public.user_filters USING btree (full_user_id, filter_id);


--
-- Name: ignored_users_ignored_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ignored_users_ignored_user_id ON public.ignored_users USING btree (ignored_user_id);


--
-- Name: ignored_users_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ignored_users_uniqueness ON public.ignored_users USING btree (ignorer_user_id, ignored_user_id);


--
-- Name: instance_map_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX instance_map_idx ON public.instance_map USING btree (instance_name);


--
-- Name: local_current_membership_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX local_current_membership_idx ON public.local_current_membership USING btree (user_id, room_id);


--
-- Name: local_current_membership_room_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX local_current_membership_room_idx ON public.local_current_membership USING btree (room_id);


--
-- Name: local_media_repository_thumbn_media_id_width_height_method_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX local_media_repository_thumbn_media_id_width_height_method_key ON public.local_media_repository_thumbnails USING btree (media_id, thumbnail_width, thumbnail_height, thumbnail_type, thumbnail_method);


--
-- Name: local_media_repository_thumbnails_media_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX local_media_repository_thumbnails_media_id ON public.local_media_repository_thumbnails USING btree (media_id);


--
-- Name: local_media_repository_url_cache_by_url_download_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX local_media_repository_url_cache_by_url_download_ts ON public.local_media_repository_url_cache USING btree (url, download_ts);


--
-- Name: local_media_repository_url_cache_expires_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX local_media_repository_url_cache_expires_idx ON public.local_media_repository_url_cache USING btree (expires_ts);


--
-- Name: local_media_repository_url_cache_media_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX local_media_repository_url_cache_media_idx ON public.local_media_repository_url_cache USING btree (media_id);


--
-- Name: local_media_repository_url_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX local_media_repository_url_idx ON public.local_media_repository USING btree (created_ts) WHERE (url_cache IS NOT NULL);


--
-- Name: login_tokens_auth_provider_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX login_tokens_auth_provider_idx ON public.login_tokens USING btree (auth_provider_id, auth_provider_session_id);


--
-- Name: login_tokens_expiry_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX login_tokens_expiry_time_idx ON public.login_tokens USING btree (expiry_ts);


--
-- Name: monthly_active_users_time_stamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX monthly_active_users_time_stamp ON public.monthly_active_users USING btree ("timestamp");


--
-- Name: monthly_active_users_users; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monthly_active_users_users ON public.monthly_active_users USING btree (user_id);


--
-- Name: msc4242_state_dag_edges_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX msc4242_state_dag_edges_key ON public.msc4242_state_dag_edges USING btree (room_id, event_id, prev_state_event_id);


--
-- Name: msc4242_state_dag_room; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msc4242_state_dag_room ON public.msc4242_state_dag_forward_extremities USING btree (room_id);


--
-- Name: open_id_tokens_ts_valid_until_ms; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX open_id_tokens_ts_valid_until_ms ON public.open_id_tokens USING btree (ts_valid_until_ms);


--
-- Name: partial_state_events_room_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX partial_state_events_room_id_idx ON public.partial_state_events USING btree (room_id);


--
-- Name: presence_stream_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX presence_stream_id ON public.presence_stream USING btree (stream_id, user_id);


--
-- Name: presence_stream_state_not_offline_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX presence_stream_state_not_offline_idx ON public.presence_stream USING btree (state) WHERE (state <> 'offline'::text);


--
-- Name: presence_stream_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX presence_stream_user_id ON public.presence_stream USING btree (user_id);


--
-- Name: profiles_full_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX profiles_full_user_id_key ON public.profiles USING btree (full_user_id);


--
-- Name: public_room_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX public_room_index ON public.rooms USING btree (is_public);


--
-- Name: push_rules_enable_user_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX push_rules_enable_user_name ON public.push_rules_enable USING btree (user_name);


--
-- Name: push_rules_stream_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX push_rules_stream_id ON public.push_rules_stream USING btree (stream_id);


--
-- Name: push_rules_stream_user_stream_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX push_rules_stream_user_stream_id ON public.push_rules_stream USING btree (user_id, stream_id);


--
-- Name: push_rules_user_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX push_rules_user_name ON public.push_rules USING btree (user_name);


--
-- Name: ratelimit_override_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ratelimit_override_idx ON public.ratelimit_override USING btree (user_id);


--
-- Name: receipts_graph_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX receipts_graph_unique_index ON public.receipts_graph USING btree (room_id, receipt_type, user_id) WHERE (thread_id IS NULL);


--
-- Name: receipts_linearized_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipts_linearized_id ON public.receipts_linearized USING btree (stream_id);


--
-- Name: receipts_linearized_room_stream; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipts_linearized_room_stream ON public.receipts_linearized USING btree (room_id, stream_id);


--
-- Name: receipts_linearized_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX receipts_linearized_unique_index ON public.receipts_linearized USING btree (room_id, receipt_type, user_id) WHERE (thread_id IS NULL);


--
-- Name: receipts_linearized_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipts_linearized_user ON public.receipts_linearized USING btree (user_id);


--
-- Name: received_transactions_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX received_transactions_ts ON public.received_transactions USING btree (ts);


--
-- Name: redactions_have_censored_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX redactions_have_censored_ts ON public.redactions USING btree (received_ts) WHERE (NOT have_censored);


--
-- Name: redactions_redacts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX redactions_redacts ON public.redactions USING btree (redacts);


--
-- Name: refresh_tokens_next_token_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX refresh_tokens_next_token_id ON public.refresh_tokens USING btree (next_token_id) WHERE (next_token_id IS NOT NULL);


--
-- Name: remote_media_repository_thumbn_media_origin_id_width_height_met; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX remote_media_repository_thumbn_media_origin_id_width_height_met ON public.remote_media_cache_thumbnails USING btree (media_origin, media_id, thumbnail_width, thumbnail_height, thumbnail_type, thumbnail_method);


--
-- Name: room_account_data_stream_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_account_data_stream_id ON public.room_account_data USING btree (user_id, stream_id);


--
-- Name: room_alias_servers_alias; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_alias_servers_alias ON public.room_alias_servers USING btree (room_alias);


--
-- Name: room_aliases_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_aliases_id ON public.room_aliases USING btree (room_id);


--
-- Name: room_membership_user_room_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_membership_user_room_idx ON public.room_memberships USING btree (user_id, room_id);


--
-- Name: room_memberships_room_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_memberships_room_id ON public.room_memberships USING btree (room_id);


--
-- Name: room_memberships_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_memberships_user_id ON public.room_memberships USING btree (user_id);


--
-- Name: room_memberships_user_room_forgotten; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_memberships_user_room_forgotten ON public.room_memberships USING btree (user_id, room_id) WHERE (forgotten = 1);


--
-- Name: room_retention_max_lifetime_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX room_retention_max_lifetime_idx ON public.room_retention USING btree (max_lifetime);


--
-- Name: room_stats_earliest_token_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX room_stats_earliest_token_idx ON public.room_stats_earliest_token USING btree (room_id);


--
-- Name: room_stats_state_room; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX room_stats_state_room ON public.room_stats_state USING btree (room_id);


--
-- Name: scheduled_tasks_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_tasks_status ON public.scheduled_tasks USING btree (status);


--
-- Name: scheduled_tasks_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scheduled_tasks_timestamp ON public.scheduled_tasks USING btree ("timestamp");


--
-- Name: sliding_sync_connection_lazy_members_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sliding_sync_connection_lazy_members_idx ON public.sliding_sync_connection_lazy_members USING btree (connection_key, room_id, user_id);


--
-- Name: sliding_sync_connection_lazy_members_pos_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sliding_sync_connection_lazy_members_pos_idx ON public.sliding_sync_connection_lazy_members USING btree (connection_key, connection_position) WHERE (connection_position IS NOT NULL);


--
-- Name: sliding_sync_connection_positions_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sliding_sync_connection_positions_key ON public.sliding_sync_connection_positions USING btree (connection_key);


--
-- Name: sliding_sync_connection_positions_ts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sliding_sync_connection_positions_ts_idx ON public.sliding_sync_connection_positions USING btree (created_ts);


--
-- Name: sliding_sync_connection_required_state_conn_pos; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sliding_sync_connection_required_state_conn_pos ON public.sliding_sync_connection_required_state USING btree (connection_key);


--
-- Name: sliding_sync_connection_room_configs_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sliding_sync_connection_room_configs_idx ON public.sliding_sync_connection_room_configs USING btree (connection_position, room_id);


--
-- Name: sliding_sync_connection_streams_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sliding_sync_connection_streams_idx ON public.sliding_sync_connection_streams USING btree (connection_position, room_id, stream);


--
-- Name: sliding_sync_connections_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sliding_sync_connections_idx ON public.sliding_sync_connections USING btree (user_id, effective_device_id, conn_id);


--
-- Name: sliding_sync_connections_ts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sliding_sync_connections_ts_idx ON public.sliding_sync_connections USING btree (created_ts);


--
-- Name: sliding_sync_joined_rooms_event_stream_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sliding_sync_joined_rooms_event_stream_ordering ON public.sliding_sync_joined_rooms USING btree (event_stream_ordering);


--
-- Name: sliding_sync_membership_snapshots_event_stream_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sliding_sync_membership_snapshots_event_stream_ordering ON public.sliding_sync_membership_snapshots USING btree (event_stream_ordering);


--
-- Name: sliding_sync_membership_snapshots_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sliding_sync_membership_snapshots_user_id ON public.sliding_sync_membership_snapshots USING btree (user_id);


--
-- Name: state_group_edges_prev_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX state_group_edges_prev_idx ON public.state_group_edges USING btree (prev_state_group);


--
-- Name: state_group_edges_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX state_group_edges_unique_idx ON public.state_group_edges USING btree (state_group, prev_state_group);


--
-- Name: state_groups_pending_deletion_insertion_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX state_groups_pending_deletion_insertion_ts ON public.state_groups_pending_deletion USING btree (insertion_ts);


--
-- Name: state_groups_pending_deletion_state_group; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX state_groups_pending_deletion_state_group ON public.state_groups_pending_deletion USING btree (state_group);


--
-- Name: state_groups_persisting_instance_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX state_groups_persisting_instance_name ON public.state_groups_persisting USING btree (instance_name);


--
-- Name: state_groups_room_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX state_groups_room_id_idx ON public.state_groups USING btree (room_id);


--
-- Name: state_groups_state_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX state_groups_state_type_idx ON public.state_groups_state USING btree (state_group, type, state_key);


--
-- Name: sticky_events_room_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sticky_events_room_idx ON public.sticky_events USING btree (room_id, event_stream_ordering);


--
-- Name: stream_ordering_to_exterm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stream_ordering_to_exterm_idx ON public.stream_ordering_to_exterm USING btree (stream_ordering);


--
-- Name: stream_ordering_to_exterm_rm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stream_ordering_to_exterm_rm_idx ON public.stream_ordering_to_exterm USING btree (room_id, stream_ordering);


--
-- Name: stream_positions_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX stream_positions_idx ON public.stream_positions USING btree (stream_name, instance_name);


--
-- Name: thread_subscriptions_by_event; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX thread_subscriptions_by_event ON public.thread_subscriptions USING btree (event_id);


--
-- Name: thread_subscriptions_by_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX thread_subscriptions_by_user ON public.thread_subscriptions USING btree (user_id, stream_id);


--
-- Name: thread_subscriptions_user_room; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX thread_subscriptions_user_room ON public.thread_subscriptions USING btree (user_id, room_id);


--
-- Name: threads_ordering_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX threads_ordering_idx ON public.threads USING btree (room_id, topological_ordering, stream_ordering);


--
-- Name: threepid_guest_access_tokens_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX threepid_guest_access_tokens_index ON public.threepid_guest_access_tokens USING btree (medium, address);


--
-- Name: threepid_validation_token_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX threepid_validation_token_session_id ON public.threepid_validation_token USING btree (session_id);


--
-- Name: timeline_gaps_room_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX timeline_gaps_room_id ON public.timeline_gaps USING btree (room_id, stream_ordering);


--
-- Name: un_partial_stated_event_stream_room_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX un_partial_stated_event_stream_room_id ON public.un_partial_stated_event_stream USING btree (event_id);


--
-- Name: un_partial_stated_room_stream_room_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX un_partial_stated_room_stream_room_id ON public.un_partial_stated_room_stream USING btree (room_id);


--
-- Name: user_daily_visits_ts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_daily_visits_ts_idx ON public.user_daily_visits USING btree ("timestamp");


--
-- Name: user_daily_visits_uts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_daily_visits_uts_idx ON public.user_daily_visits USING btree (user_id, "timestamp");


--
-- Name: user_directory_room_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_directory_room_idx ON public.user_directory USING btree (room_id);


--
-- Name: user_directory_search_fts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_directory_search_fts_idx ON public.user_directory_search USING gin (vector);


--
-- Name: user_directory_search_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_directory_search_user_idx ON public.user_directory_search USING btree (user_id);


--
-- Name: user_directory_stale_remote_users_next_try_by_server_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_directory_stale_remote_users_next_try_by_server_idx ON public.user_directory_stale_remote_users USING btree (user_server_name, next_try_at_ts);


--
-- Name: user_directory_stale_remote_users_next_try_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_directory_stale_remote_users_next_try_idx ON public.user_directory_stale_remote_users USING btree (next_try_at_ts, user_server_name);


--
-- Name: user_directory_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_directory_user_idx ON public.user_directory USING btree (user_id);


--
-- Name: user_external_ids_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_external_ids_user_id_idx ON public.user_external_ids USING btree (user_id);


--
-- Name: user_filters_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_filters_unique ON public.user_filters USING btree (user_id, filter_id);


--
-- Name: user_ips_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_ips_device_id ON public.user_ips USING btree (user_id, device_id, last_seen);


--
-- Name: user_ips_last_seen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_ips_last_seen ON public.user_ips USING btree (user_id, last_seen);


--
-- Name: user_ips_last_seen_only; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_ips_last_seen_only ON public.user_ips USING btree (last_seen);


--
-- Name: user_ips_user_token_ip_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_ips_user_token_ip_unique_index ON public.user_ips USING btree (user_id, access_token, ip);


--
-- Name: user_reports_target_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_reports_target_user_id ON public.user_reports USING btree (target_user_id);


--
-- Name: user_reports_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_reports_user_id ON public.user_reports USING btree (user_id);


--
-- Name: user_signature_stream_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_signature_stream_idx ON public.user_signature_stream USING btree (stream_id);


--
-- Name: user_threepid_id_server_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_threepid_id_server_idx ON public.user_threepid_id_server USING btree (user_id, medium, address, id_server);


--
-- Name: user_threepids_medium_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_threepids_medium_address ON public.user_threepids USING btree (medium, address);


--
-- Name: user_threepids_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_threepids_user_id ON public.user_threepids USING btree (user_id);


--
-- Name: users_creation_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_creation_ts ON public.users USING btree (creation_ts);


--
-- Name: users_have_local_media; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_have_local_media ON public.local_media_repository USING btree (user_id, created_ts);


--
-- Name: users_in_public_rooms_r_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_in_public_rooms_r_idx ON public.users_in_public_rooms USING btree (room_id);


--
-- Name: users_in_public_rooms_u_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_in_public_rooms_u_idx ON public.users_in_public_rooms USING btree (user_id, room_id);


--
-- Name: users_who_share_private_rooms_o_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_who_share_private_rooms_o_idx ON public.users_who_share_private_rooms USING btree (other_user_id);


--
-- Name: users_who_share_private_rooms_r_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_who_share_private_rooms_r_idx ON public.users_who_share_private_rooms USING btree (room_id);


--
-- Name: users_who_share_private_rooms_u_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_who_share_private_rooms_u_idx ON public.users_who_share_private_rooms USING btree (user_id, other_user_id, room_id);


--
-- Name: worker_locks_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX worker_locks_key ON public.worker_locks USING btree (lock_name, lock_key);


--
-- Name: worker_read_write_locks_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX worker_read_write_locks_key ON public.worker_read_write_locks USING btree (lock_name, lock_key, token);


--
-- Name: worker_read_write_locks_mode_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX worker_read_write_locks_mode_key ON public.worker_read_write_locks_mode USING btree (lock_name, lock_key);


--
-- Name: worker_read_write_locks_mode_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX worker_read_write_locks_mode_type ON public.worker_read_write_locks_mode USING btree (lock_name, lock_key, write_lock);


--
-- Name: worker_read_write_locks_write; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX worker_read_write_locks_write ON public.worker_read_write_locks USING btree (lock_name, lock_key) WHERE write_lock;


--
-- Name: current_state_events check_event_stream_ordering; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_event_stream_ordering BEFORE INSERT OR UPDATE ON public.current_state_events FOR EACH ROW EXECUTE FUNCTION public.check_event_stream_ordering();


--
-- Name: local_current_membership check_event_stream_ordering; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_event_stream_ordering BEFORE INSERT OR UPDATE ON public.local_current_membership FOR EACH ROW EXECUTE FUNCTION public.check_event_stream_ordering();


--
-- Name: room_memberships check_event_stream_ordering; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_event_stream_ordering BEFORE INSERT OR UPDATE ON public.room_memberships FOR EACH ROW EXECUTE FUNCTION public.check_event_stream_ordering();


--
-- Name: partial_state_events check_partial_state_events; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_partial_state_events BEFORE INSERT OR UPDATE ON public.partial_state_events FOR EACH ROW EXECUTE FUNCTION public.check_partial_state_events();


--
-- Name: worker_read_write_locks delete_read_write_lock_parent_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_read_write_lock_parent_trigger AFTER DELETE ON public.worker_read_write_locks FOR EACH ROW EXECUTE FUNCTION public.delete_read_write_lock_parent();


--
-- Name: worker_read_write_locks upsert_read_write_lock_parent_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER upsert_read_write_lock_parent_trigger BEFORE INSERT ON public.worker_read_write_locks FOR EACH ROW EXECUTE FUNCTION public.upsert_read_write_lock_parent();


--
-- Name: access_tokens access_tokens_refresh_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_refresh_token_id_fkey FOREIGN KEY (refresh_token_id) REFERENCES public.refresh_tokens(id) ON DELETE CASCADE;


--
-- Name: destination_rooms destination_rooms_destination_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destination_rooms
    ADD CONSTRAINT destination_rooms_destination_fkey FOREIGN KEY (destination) REFERENCES public.destinations(destination);


--
-- Name: destination_rooms destination_rooms_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destination_rooms
    ADD CONSTRAINT destination_rooms_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id);


--
-- Name: event_edges event_edges_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_edges
    ADD CONSTRAINT event_edges_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(event_id);


--
-- Name: event_failed_pull_attempts event_failed_pull_attempts_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_failed_pull_attempts
    ADD CONSTRAINT event_failed_pull_attempts_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id);


--
-- Name: event_forward_extremities event_forward_extremities_event_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_forward_extremities
    ADD CONSTRAINT event_forward_extremities_event_id FOREIGN KEY (event_id) REFERENCES public.events(event_id) DEFERRABLE INITIALLY DEFERRED NOT VALID;


--
-- Name: current_state_events event_stream_ordering_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.current_state_events
    ADD CONSTRAINT event_stream_ordering_fkey FOREIGN KEY (event_stream_ordering) REFERENCES public.events(stream_ordering) NOT VALID;


--
-- Name: local_current_membership event_stream_ordering_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_current_membership
    ADD CONSTRAINT event_stream_ordering_fkey FOREIGN KEY (event_stream_ordering) REFERENCES public.events(stream_ordering) NOT VALID;


--
-- Name: room_memberships event_stream_ordering_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_memberships
    ADD CONSTRAINT event_stream_ordering_fkey FOREIGN KEY (event_stream_ordering) REFERENCES public.events(stream_ordering) NOT VALID;


--
-- Name: event_txn_id_device_id event_txn_id_device_id_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_txn_id_device_id
    ADD CONSTRAINT event_txn_id_device_id_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(event_id) ON DELETE CASCADE;


--
-- Name: event_txn_id_device_id event_txn_id_device_id_user_id_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_txn_id_device_id
    ADD CONSTRAINT event_txn_id_device_id_user_id_device_id_fkey FOREIGN KEY (user_id, device_id) REFERENCES public.devices(user_id, device_id) ON DELETE CASCADE;


--
-- Name: msc4242_state_dag_edges msc4242_state_dag_edges_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msc4242_state_dag_edges
    ADD CONSTRAINT msc4242_state_dag_edges_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(event_id);


--
-- Name: msc4242_state_dag_edges msc4242_state_dag_edges_prev_state_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msc4242_state_dag_edges
    ADD CONSTRAINT msc4242_state_dag_edges_prev_state_event_id_fkey FOREIGN KEY (prev_state_event_id) REFERENCES public.events(event_id);


--
-- Name: msc4242_state_dag_edges msc4242_state_dag_edges_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msc4242_state_dag_edges
    ADD CONSTRAINT msc4242_state_dag_edges_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE;


--
-- Name: msc4242_state_dag_forward_extremities msc4242_state_dag_forward_extremities_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msc4242_state_dag_forward_extremities
    ADD CONSTRAINT msc4242_state_dag_forward_extremities_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(event_id) ON DELETE CASCADE;


--
-- Name: msc4242_state_dag_forward_extremities msc4242_state_dag_forward_extremities_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msc4242_state_dag_forward_extremities
    ADD CONSTRAINT msc4242_state_dag_forward_extremities_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE;


--
-- Name: partial_state_events partial_state_events_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partial_state_events
    ADD CONSTRAINT partial_state_events_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(event_id);


--
-- Name: partial_state_events partial_state_events_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partial_state_events
    ADD CONSTRAINT partial_state_events_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.partial_state_rooms(room_id);


--
-- Name: partial_state_rooms partial_state_rooms_join_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partial_state_rooms
    ADD CONSTRAINT partial_state_rooms_join_event_id_fkey FOREIGN KEY (join_event_id) REFERENCES public.events(event_id);


--
-- Name: partial_state_rooms partial_state_rooms_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partial_state_rooms
    ADD CONSTRAINT partial_state_rooms_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id);


--
-- Name: partial_state_rooms_servers partial_state_rooms_servers_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partial_state_rooms_servers
    ADD CONSTRAINT partial_state_rooms_servers_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.partial_state_rooms(room_id);


--
-- Name: per_user_experimental_features per_user_experimental_features_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.per_user_experimental_features
    ADD CONSTRAINT per_user_experimental_features_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(name);


--
-- Name: refresh_tokens refresh_tokens_next_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_next_token_id_fkey FOREIGN KEY (next_token_id) REFERENCES public.refresh_tokens(id) ON DELETE CASCADE;


--
-- Name: sliding_sync_connection_lazy_members sliding_sync_connection_lazy_members_connection_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_connection_lazy_members
    ADD CONSTRAINT sliding_sync_connection_lazy_members_connection_key_fkey FOREIGN KEY (connection_key) REFERENCES public.sliding_sync_connections(connection_key) ON DELETE CASCADE;


--
-- Name: sliding_sync_connection_lazy_members sliding_sync_connection_lazy_members_connection_position_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_connection_lazy_members
    ADD CONSTRAINT sliding_sync_connection_lazy_members_connection_position_fkey FOREIGN KEY (connection_position) REFERENCES public.sliding_sync_connection_positions(connection_position) ON DELETE CASCADE;


--
-- Name: sliding_sync_connection_positions sliding_sync_connection_positions_connection_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_connection_positions
    ADD CONSTRAINT sliding_sync_connection_positions_connection_key_fkey FOREIGN KEY (connection_key) REFERENCES public.sliding_sync_connections(connection_key) ON DELETE CASCADE;


--
-- Name: sliding_sync_connection_required_state sliding_sync_connection_required_state_connection_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_connection_required_state
    ADD CONSTRAINT sliding_sync_connection_required_state_connection_key_fkey FOREIGN KEY (connection_key) REFERENCES public.sliding_sync_connections(connection_key) ON DELETE CASCADE;


--
-- Name: sliding_sync_connection_room_configs sliding_sync_connection_room_configs_connection_position_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_connection_room_configs
    ADD CONSTRAINT sliding_sync_connection_room_configs_connection_position_fkey FOREIGN KEY (connection_position) REFERENCES public.sliding_sync_connection_positions(connection_position) ON DELETE CASCADE;


--
-- Name: sliding_sync_connection_room_configs sliding_sync_connection_room_configs_required_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_connection_room_configs
    ADD CONSTRAINT sliding_sync_connection_room_configs_required_state_id_fkey FOREIGN KEY (required_state_id) REFERENCES public.sliding_sync_connection_required_state(required_state_id);


--
-- Name: sliding_sync_connection_streams sliding_sync_connection_streams_connection_position_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_connection_streams
    ADD CONSTRAINT sliding_sync_connection_streams_connection_position_fkey FOREIGN KEY (connection_position) REFERENCES public.sliding_sync_connection_positions(connection_position) ON DELETE CASCADE;


--
-- Name: sliding_sync_joined_rooms sliding_sync_joined_rooms_event_stream_ordering_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_joined_rooms
    ADD CONSTRAINT sliding_sync_joined_rooms_event_stream_ordering_fkey FOREIGN KEY (event_stream_ordering) REFERENCES public.events(stream_ordering);


--
-- Name: sliding_sync_joined_rooms sliding_sync_joined_rooms_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_joined_rooms
    ADD CONSTRAINT sliding_sync_joined_rooms_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id);


--
-- Name: sliding_sync_joined_rooms_to_recalculate sliding_sync_joined_rooms_to_recalculate_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_joined_rooms_to_recalculate
    ADD CONSTRAINT sliding_sync_joined_rooms_to_recalculate_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id);


--
-- Name: sliding_sync_membership_snapshots sliding_sync_membership_snapshots_event_stream_ordering_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_membership_snapshots
    ADD CONSTRAINT sliding_sync_membership_snapshots_event_stream_ordering_fkey FOREIGN KEY (event_stream_ordering) REFERENCES public.events(stream_ordering);


--
-- Name: sliding_sync_membership_snapshots sliding_sync_membership_snapshots_membership_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_membership_snapshots
    ADD CONSTRAINT sliding_sync_membership_snapshots_membership_event_id_fkey FOREIGN KEY (membership_event_id) REFERENCES public.events(event_id);


--
-- Name: sliding_sync_membership_snapshots sliding_sync_membership_snapshots_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sliding_sync_membership_snapshots
    ADD CONSTRAINT sliding_sync_membership_snapshots_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id);


--
-- Name: thread_subscriptions thread_subscriptions_fk_events; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thread_subscriptions
    ADD CONSTRAINT thread_subscriptions_fk_events FOREIGN KEY (event_id) REFERENCES public.events(event_id) ON DELETE CASCADE;


--
-- Name: thread_subscriptions thread_subscriptions_fk_rooms; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thread_subscriptions
    ADD CONSTRAINT thread_subscriptions_fk_rooms FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE;


--
-- Name: thread_subscriptions thread_subscriptions_fk_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thread_subscriptions
    ADD CONSTRAINT thread_subscriptions_fk_users FOREIGN KEY (user_id) REFERENCES public.users(name);


--
-- Name: ui_auth_sessions_credentials ui_auth_sessions_credentials_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ui_auth_sessions_credentials
    ADD CONSTRAINT ui_auth_sessions_credentials_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.ui_auth_sessions(session_id);


--
-- Name: ui_auth_sessions_ips ui_auth_sessions_ips_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ui_auth_sessions_ips
    ADD CONSTRAINT ui_auth_sessions_ips_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.ui_auth_sessions(session_id);


--
-- Name: un_partial_stated_event_stream un_partial_stated_event_stream_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.un_partial_stated_event_stream
    ADD CONSTRAINT un_partial_stated_event_stream_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(event_id) ON DELETE CASCADE;


--
-- Name: un_partial_stated_room_stream un_partial_stated_room_stream_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.un_partial_stated_room_stream
    ADD CONSTRAINT un_partial_stated_room_stream_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE;


--
-- Name: users_to_send_full_presence_to users_to_send_full_presence_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_to_send_full_presence_to
    ADD CONSTRAINT users_to_send_full_presence_to_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(name);


--
-- Name: worker_read_write_locks worker_read_write_locks_lock_name_lock_key_write_lock_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_read_write_locks
    ADD CONSTRAINT worker_read_write_locks_lock_name_lock_key_write_lock_fkey FOREIGN KEY (lock_name, lock_key, write_lock) REFERENCES public.worker_read_write_locks_mode(lock_name, lock_key, write_lock);


--
-- Name: worker_read_write_locks_mode worker_read_write_locks_mode_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_read_write_locks_mode
    ADD CONSTRAINT worker_read_write_locks_mode_foreign FOREIGN KEY (lock_name, lock_key, token) REFERENCES public.worker_read_write_locks(lock_name, lock_key, token) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--


