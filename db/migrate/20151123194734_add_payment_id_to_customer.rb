class AddPaymentIdToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :payment_processor_customer_id, :string
  end
end
