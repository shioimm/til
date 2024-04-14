# https://exercism.org/tracks/ruby/exercises/savings-account

module SavingsAccount
  def self.interest_rate(balance)
    if    balance >= 0.0    && balance < 1000.0 then 0.5
    elsif balance >= 1000.0 && balance < 5000.0 then 1.621
    elsif balance >= 5000.0                     then 2.475
    elsif balance <  0.0                        then 3.213
    end
  end

  def self.annual_balance_update(balance)
    balance + balance * (interest_rate(balance) / 100)
  end

  def self.years_before_desired_balance(current_balance, desired_balance)
    (1..).inject(current_balance) { |balance, year|
      annual_updated_balance = annual_balance_update(balance)

      if annual_updated_balance >= desired_balance
        return year
      else
        annual_updated_balance
      end
    }
  end
end
