ActiveRecord::Schema.define do

   create_table :epa do |t|
     t.string   :year
     t.string   :mfr
     t.string   :car_line
     t.integer   :city_mpg
     t.integer   :hwy_mpg
     t.integer  :comb_mpg
     t.timestamps
   end
 
end