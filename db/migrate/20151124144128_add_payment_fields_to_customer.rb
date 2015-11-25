class AddPaymentFieldsToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :payment_processor_customer_id, :string
    add_column :customers, :subscription, :string
  end
end
