class User
	@db = "customorm"
	attr_accessor :fname
	attr_accessor :lname
	attr_accessor :bday
	attr_accessor :id
	attr_accessor :datecreated

	def initialize(atts = {})
		atts.each { |key, val| 
			instance_variable_set("@#{key}", val)
		}
	end

	def self.run_cmd(cmd)
		# Can't use -d flag because you have to be the owner of the db and this code defaults to posgresql as user
		`psql #{@db} -c "#{cmd}"` 
	end
	
	def self.find(id)
		cmd = "SELECT * FROM users WHERE id=#{id}"
		make_users(run_cmd(cmd))
	end

	def self.where(user_hash)
		cmd = "SELECT * FROM users WHERE #{user_hash.map { |k,v| "#{k}='#{v}'" }.join(" AND ")}"
		make_users(run_cmd(cmd))
	end

	def self.all
		cmd = "SELECT * FROM users"
		make_users(run_cmd(cmd))
	end

	def self.last
		cmd = "SELECT * FROM users ORDER BY datecreated DESC LIMIT 1"
		make_users(run_cmd(cmd))
	end

	def self.first
		cmd = "SELECT * FROM users ORDER BY datecreated LIMIT 1"
		make_users(run_cmd(cmd))
	end

	def self.create(atts = {})
		cmd = "INSERT INTO users (#{atts.keys.map {|key| key.to_s}.join(",")}) VALUES (#{atts.values.map { |val| "'#{val}'" }.join(",")})"
		run_cmd(cmd)
		last
	end

	def insert
		cmd = "INSERT INTO users (#{instance_variables.map { |k| k.to_s.delete("@") }.join(",")}) VALUES (#{instance_variables.map { |k| "'#{instance_variable_get(k).to_s}'" }.join(",")})"
		self.class.run_cmd(cmd)
		user = User.last[0]
		@id = user.id
		@datecreated = user.datecreated
	end

	def destroy_all
		cmd = "DELETE FROM users"
		self.class.run_cmd(cmd)
	end

	def save
		cmd = "UPDATE users SET #{instance_variables.map { |k,v| "#{k.to_s.delete("@")} = '#{instance_variable_get(k)}'" }.join(",")} WHERE id=#{@id}"
		self.class.run_cmd(cmd)
	end

	def destroy
		cmd = "DELETE FROM users WHERE id=#{@id}"
		self.class.run_cmd(cmd)
	end

	def self.make_users(result)
		array = result.split("\n").map { |e| 
			e.split("|").map { |i| 
				i.strip
			}
		}
		
		col_and_results = {columns: array[0], results: array[2..-2]}
		users_arr = []

		col_and_results[:results].each { |user| 
			users_arr.push(User.new(Hash[col_and_results[:columns].zip(user)]))
		}

		users_arr
	end
	
end

puts User.find(1).inspect
puts ' '
puts User.where({:lname => "Stinnett"}).inspect
puts ' '
puts User.all.inspect
puts ' '
puts User.last.inspect
puts ' '
puts User.first.inspect

puts User.create({fname: "Zach", lname: "Jones", bday: "1988-12-05"}).inspect

user = User.new({fname: "Stephen", lname: "Zimmerman", bday: "1976-11-01"})
puts user.insert
user.fname = "StephenNewName"
user.lname = "ZimmsNewLastNAme"
user.bday = "2016-07-15"
puts user.save
puts User.last.inspect
user.destroy
puts User.find(user.id)

