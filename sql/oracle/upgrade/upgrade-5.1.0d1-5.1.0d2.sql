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


@@ ../acs-mail-packages-create.sql

create or replace package acs_mail_queue_message
as

 function new (
  mail_link_id    in acs_mail_links.mail_link_id%TYPE default null,
  body_id         in acs_mail_bodies.body_id%TYPE,
  context_id      in acs_objects.context_id%TYPE    default null,
  creation_date   in acs_objects.creation_date%TYPE default sysdate,
  creation_user   in acs_objects.creation_user%TYPE default null,
  creation_ip     in acs_objects.creation_ip%TYPE   default null,
  object_type     in acs_objects.object_type%TYPE   default 'acs_mail_link',
  package_id      in acs_objects.package_id%TYPE    default null
 ) return acs_objects.object_id%TYPE;

 procedure del (
  message_id in acs_mail_links.mail_link_id%TYPE
 );
end acs_mail_queue_message;
/
show errors

create or replace package body acs_mail_queue_message
as

 function new (
  mail_link_id    in acs_mail_links.mail_link_id%TYPE default null,
  body_id         in acs_mail_bodies.body_id%TYPE,
  context_id      in acs_objects.context_id%TYPE    default null,
  creation_date   in acs_objects.creation_date%TYPE default sysdate,
  creation_user   in acs_objects.creation_user%TYPE default null,
  creation_ip     in acs_objects.creation_ip%TYPE   default null,
  object_type     in acs_objects.object_type%TYPE   default 'acs_mail_link',
  package_id      in acs_objects.package_id%TYPE    default null
 ) return acs_objects.object_id%TYPE
 is
     v_object_id acs_objects.object_id%TYPE;
 begin
     v_object_id := acs_mail_link.new (
         mail_link_id => mail_link_id,
	 body_id => body_id,		      
         context_id => context_id,
         creation_date => creation_date,
         creation_user => creation_user,
         creation_ip => creation_ip,
         object_type => object_type,
	 package_id => package_id
     );

     insert into acs_mail_queue_messages ( message_id )
         values ( v_object_id );

     return v_object_id;
 end;

 procedure del (
  message_id in acs_mail_links.mail_link_id%TYPE
 )
 is
 begin
     delete from acs_mail_queue_messages
         where message_id = acs_mail_queue_message.del.message_id;
     acs_mail_link.del(message_id);
 end;

end acs_mail_queue_message;
/
show errors

@@ ../acs-mail-nt-create.sql
