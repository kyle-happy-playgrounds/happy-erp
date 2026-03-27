class AddDealerCostToPwProducts2021Raw < ActiveRecord::Migration[7.1]
  def change
    add_column :pw_products_2021_raw, :dealer_cost, :decimal,
      precision: 10,
      scale: 2,
      default: "0.0",
      null: false
  end
end
