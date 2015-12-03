create or replace function acs_mail_body__body_p(integer) 
returns boolean as '
declare
    p_object_id		alias for $1;
    v_check_body_id integer;
begin
	select count(body_id) into v_check_body_id
	  from acs_mail_bodies where body_id = p_object_id;

     if v_check_body_id <> 0 then
         return ''t'';
     else
         return ''f'';
     end if;
end;
' language 'plpgsql' stable;
