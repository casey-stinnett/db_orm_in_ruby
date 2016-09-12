# db_orm_in_ruby
For my test ORM that I am making for W4D1

# How to use
If you want to create a user record on the fly, use this code:
```ruby
User.create({fname: "Zach", lname: "Jones", bday: "1988-12-05"})
```

If you want to create a user object first and then insert into db, do this:
```ruby
user = User.new({fname: "Zach", lname: "Jones", bday: "1988-12-05"})   
user.insert
```
