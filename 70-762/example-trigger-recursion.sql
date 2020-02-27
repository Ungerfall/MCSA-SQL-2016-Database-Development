create table examples.users (id int not null, username nvarchar(255) not null);
go
create trigger examples.TriggerUsers
on examples.users
after UPDATE
as
begin
	RAISERROR ('trigger fired', 0, 0) with nowait;
	declare @id int = (select top (1) id from inserted order by id desc);
	update examples.users
	set username = UPPER(username)
	where id = @id;
end;
go

insert into examples.users (id, username) values (1, 'leonid');

update examples.users
set username = 'leonid2'

select * from examples.users;

