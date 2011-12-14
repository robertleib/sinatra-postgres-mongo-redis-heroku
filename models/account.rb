class Account < ActiveRecord::Base
   validates_presence_of :name, :owner_id
   validates_uniqueness_of :name, :case_sensitive => false
   
   after_create :capitalize_name
   
   @queue = :critical
   
   def capitalize_name
     Resque.enqueue(Account, :capitalize_name, self.id)
   end
   
   def self.capitalize_name(aid)
     a = Account.find(aid)
     a.name = a.name.capitalize
     a.save
   end
   
   def self.perform(method, id)
     if self.respond_to? method.to_sym
       self.send method.to_sym, id
     end
   end
end