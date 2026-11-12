create table suppliers (
    sid int primary key,
    sname varchar(50) not null,
    city varchar(50) not null
);

create table parts (
    pid int primary key,
    pname varchar(50) not null,
    color varchar(20) not null
);

create table catalog (
    sid int,
    pid int,
    cost decimal(10, 2) not null check (cost >= 0),
    primary key (sid, pid),
    foreign key (sid) references suppliers(sid) on delete cascade,
    foreign key (pid) references parts(pid) on delete cascade
);

insert into suppliers values
    (10001, 'acme widget', 'bangalore'),
    (10002, 'johns', 'kolkata'),
    (10003, 'vimal', 'mumbai'),
    (10004, 'reliance', 'delhi');

insert into parts values
    (20001, 'book', 'red'),
    (20002, 'pen', 'red'),
    (20003, 'pencil', 'green'),
    (20004, 'mobile', 'green'),
    (20005, 'charger', 'black');

insert into catalog values
    (10001, 20001, 10),
    (10001, 20002, 10),
    (10001, 20003, 30),
    (10001, 20004, 10),
    (10001, 20005, 10),
    (10002, 20001, 10),
    (10002, 20002, 20),
    (10003, 20003, 30),
    (10004, 20003, 40);

select p.pname
from parts p
where exists (
    select 1
    from catalog c
    where c.pid = p.pid
);

select s.sname
from suppliers s
where not exists (
    select p.pid
    from parts p
    where not exists (
        select c.pid
        from catalog c
        where c.sid = s.sid
          and c.pid = p.pid
    )
);

select s.sname
from suppliers s
where not exists (
    select p.pid
    from parts p
    where p.color = 'red'
      and not exists (
          select c.pid
          from catalog c
          where c.sid = s.sid
            and c.pid = p.pid
      )
);

select p.pname
from parts p
join catalog c on p.pid = c.pid
join suppliers s on c.sid = s.sid
where s.sname = 'acme widget'
  and not exists (
      select 1
      from catalog c2
      join suppliers s2 on c2.sid = s2.sid
      where c2.pid = p.pid
        and s2.sname <> 'acme widget'
  );

select distinct c.sid
from catalog c
where c.cost > (
    select avg(c2.cost)
    from catalog c2
    where c2.pid = c.pid
);

select p.pid, p.pname, s.sname, c.cost
from suppliers s
join catalog c on s.sid = c.sid
join parts p on c.pid = p.pid
where c.cost = (
    select max(c2.cost)
    from catalog c2
    where c2.pid = c.pid
);

select p.pname, s.sname, c.cost
from suppliers s
join catalog c on s.sid = c.sid
join parts p on c.pid = p.pid
where c.cost >= all (
    select c2.cost
    from catalog c2
);

select s.sid, s.sname
from suppliers s
where not exists (
    select 1
    from catalog c
    join parts p on c.pid = p.pid
    where c.sid = s.sid
      and p.color = 'red'
);

select s.sid, s.sname, sum(c.cost) as total_supplied_value
from suppliers s
join catalog c on s.sid = c.sid
group by s.sid, s.sname;

select s.sid, s.sname
from suppliers s
join catalog c on s.sid = c.sid
where c.cost < 20
group by s.sid, s.sname
having count(c.pid) >= 2;

select p.pid, p.pname, s.sname, c.cost
from suppliers s
join catalog c on s.sid = c.sid
join parts p on c.pid = p.pid
where c.cost = (
    select min(c2.cost)
    from catalog c2
    where c2.pid = c.pid
);

create view mostexpensivesupplierperpart as
select p.pid, p.pname, s.sid, s.sname, c.cost
from suppliers s
join catalog c on s.sid = c.sid
join parts p on c.pid = p.pid
where c.cost = (
    select max(c2.cost)
    from catalog c2
    where c2.pid = c.pid
);