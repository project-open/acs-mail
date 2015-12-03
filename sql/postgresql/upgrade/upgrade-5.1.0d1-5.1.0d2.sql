update acs_objects
set title = 'ACS Mail Object ' || object_id
where object_type = 'acs_mail_gc_object';

update acs_objects
set title = (select substr(header_subject,1,1000)
             from acs_mail_bodies
             where body_id = object_id)
where object_type = 'acs_mail_body';

update acs_objects
set title = 'ACS Mail Multipart Object ' || object_id
where object_type = 'acs_mail_multipart';

update acs_objects
set title = 'ACS Mail Message ' || object_id
where object_type = 'acs_mail_link';

update acs_objects
set title = 'Queued Message ' || object_id
where object_type = 'acs_mail_queue_message';


\i ../acs-mail-packages-create.sql

create function acs_mail_queue_message__new (integer,integer,integer,timestamptz,integer,varchar,varchar,integer)
returns integer as '
declare
	p_mail_link_id			alias for $1;    -- default null
	p_body_id			alias for $2;
	p_context_id			alias for $3;    -- default null
	p_creation_date			alias for $4;    -- default now()
	p_creation_user			alias for $5;    -- default null
	p_creation_ip			alias for $6;    -- default null
	p_object_type			alias for $7;    -- default acs_mail_link
	p_package_id			alias for $8;    -- default null
	v_mail_link_id			acs_mail_links.mail_link_id%TYPE;
begin
    v_mail_link_id := acs_mail_link__new (
		p_mail_link_id,			-- mail_link_id 
		p_body_id,			-- body_id 
		p_context_id,			-- context_id 
		p_creation_date,		-- creation_date 
		p_creation_user,		-- creation_user 
		p_creation_ip,			-- creation_ip 
		p_object_type,			-- object_type
		p_package_id			-- package_id
    );

    insert into acs_mail_queue_messages 
	 ( message_id )
    values 
	 ( v_mail_link_id );

    return v_mail_link_id;
end;' language 'plpgsql';

\i ../acs-mail-nt-create.sql
