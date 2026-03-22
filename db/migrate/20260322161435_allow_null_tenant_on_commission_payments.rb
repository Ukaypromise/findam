class AllowNullTenantOnCommissionPayments < ActiveRecord::Migration[8.0]
  def change
    change_column_null :commission_payments, :tenant_id, true
  end
end
