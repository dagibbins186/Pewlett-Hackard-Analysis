-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
     dept_no VARCHAR(4) NOT NULL,
     dept_name VARCHAR(40) NOT NULL,
     PRIMARY KEY (dept_no),
     UNIQUE (dept_name)
);
CREATE TABLE employees (
	 emp_no INT NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no)
);
CREATE TABLE dept_manager (
dept_no VARCHAR(4) NOT NULL,
    emp_no INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    PRIMARY KEY (emp_no, dept_no)
);
CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)
);
CREATE TABLE dept_emp (
	emp_no int not null,
	dept_no varchar not null,
	from_date date not null,
	to_date date not null,
	foreign key (emp_no) references employees (emp_no),
	foreign key (dept_no) references departments (dept_no),
	primary key (emp_no, dept_no)
);
CREATE TABLE titles (
	emp_no int not null,
	title varchar not null,
	from_date date not null,
	to_date date not null,
	foreign key (emp_no) references employees (emp_no),
	primary key (emp_no, from_date)
);

--Create a table of current employees eligible for retirement
select e.emp_no,
	e.first_name,
	e.last_name,
	de.to_date
into current_emp_challenge
from employees as e
	left join dept_emp as de
		on e.emp_no = de.emp_no
where (e.birth_date between '1952-01-01' and '1955-12-31')
	and (e.hire_date between '1985-01-01' and '1988-12-31')
		and de.to_date = ('9999-01-01');

--Select the titles of current employees eligible for retirement
select 
	c.emp_no,
	c.first_name,
	c.last_name,
	t.title,
	t.to_date,
	t.from_date,
	s.salary
into titles_retiring_challenge
from current_emp_challenge as c
	inner join titles as t
		on (c.emp_no = t.emp_no)
	inner join salaries as s
		on (c.emp_no = s.emp_no)
order by t.from_date DESC;

--Count the number of current employees retiring by their titles
select
	count (title),
	title
into count_titles_retiring_challenge
from titles_retiring_challenge
group by
	title
order by count desc;

--Re order and separate data to show most recent titles
select 
	emp_no, 
	first_name, 
	last_name, 
	to_date, 
	title 
into unique_titles_retiring_challenge
from 
	(select emp_no, 
	 first_name, 
	 last_name, 
	 to_date, 
	 title, row_number() over
	(partition by (first_name, last_name) 
	 order by to_date DESC) rn
	from titles_retiring_challenge
	) tmp where rn = 1
order by emp_no;

--Count the number of employees per title
select 
	count(title),
	title
into count_unique_titles_retiring_challenge
from unique_titles_retiring_challenge
group by
	title
order by count desc;

select * from unique_titles_retiring_challenge;
select * from count_unique_titles_retiring_challenge;

--Create mentorship eligibility table
select
	e.emp_no,
	e.last_name,
	e.first_name,
	e.birth_date,
	string_agg(t.title, '/') as titles,
	de.from_date,
	de.to_date
into mentor_challenge
from employees as e
	left join titles as t
		on e.emp_no = t.emp_no
	left join dept_emp as de
		on e.emp_no = de.emp_no
where e.birth_date between '1965-01-01' and '1965-12-31'
	and de.to_date = ('9999-01-01')
group by
	e.emp_no,
	e.first_name,
	e.last_name,
	de.from_date,
	de.to_date
order by last_name;

select * from mentor_challenge;
select count(*) from mentor_challenge;
