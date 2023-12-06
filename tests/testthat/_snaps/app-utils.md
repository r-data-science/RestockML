# Utils - Build and Save Plots & Datasets

    Code
      results
    Output
      $pdata0
         restock  N label
      1:      no 10   67%
      2:     yes  4   27%
      3:  unsure  1    7%
      
      $pdata1
          product_sku restock category3
       1:      141124      no   Edibles
       2:      161976      no   Edibles
       3:      186887     yes   Edibles
       4:      186889      no   Edibles
       5:      188608      no   Edibles
       6:      242186     yes   Edibles
       7:      359476      no   Edibles
       8:      487782     yes   Edibles
       9:      487784     yes   Edibles
      10:      606354      no   Edibles
      11:      733611      no   Edibles
      12:      733613      no   Edibles
      13:      733614      no   Edibles
      14:      733615      no   Edibles
      15:      733616  unsure   Edibles
      
      $pdata2
           product_sku          variable             value       pct pctlab
        1:      141124      has_oos_risk     Flag Assigned 0.9333333    93%
        2:      141124 has_sales_decline     Flag Assigned 0.2666667    27%
        3:      141124  has_sales_growth Flag Not Assigned 1.0000000   100%
        4:      141124      is_long_term     Flag Assigned 0.5333333    53%
        5:      141124    is_new_on_menu Flag Not Assigned 1.0000000   100%
       ---                                                                 
      146:      733616     is_price_high Flag Not Assigned 1.0000000   100%
      147:      733616      is_price_low     Flag Assigned 0.3333333    33%
      148:      733616        is_primary Flag Not Assigned 1.0000000   100%
      149:      733616      is_secondary Flag Not Assigned 0.7333333    73%
      150:      733616       is_trending Flag Not Assigned 0.7333333    73%
                                                                                                                                                     fac_var
        1:      <span style= 'font-size:12pt;'>**Stockout Risk**</span><br>\n         <span style= 'font-size:10pt;'>*Supply has<br>risk of Stockout*</span>
        2:          <span style= 'font-size:12pt;'>**Sales Decline**</span><br>\n         <span style= 'font-size:10pt;'>*Sales Trend<br>is Negative*</span>
        3:           <span style= 'font-size:12pt;'>**Sales Growth**</span><br>\n         <span style= 'font-size:10pt;'>*Sales Trend<br>is Positive*</span>
        4:               <span style= 'font-size:12pt;'>**Menu Classic**</span><br>\n         <span style= 'font-size:10pt;'>*Long-Term<br>Menu Item*</span>
        5:            <span style= 'font-size:12pt;'>**New Product**</span><br>\n         <span style= 'font-size:10pt;'>*Recent Addition<br>on Menu*</span>
       ---                                                                                                                                                  
      146:      <span style= 'font-size:12pt;'>**Top Shelf**</span><br>\n         <span style= 'font-size:10pt;'>*High Price<br>Relative to Category*</span>
      147:    <span style= 'font-size:12pt;'>**Bottom Shelf**</span><br>\n         <span style= 'font-size:10pt;'>*Low Price<br>Relative to Category*</span>
      148: <span style= 'font-size:12pt;'>**Primary Product**</span><br>\n         <span style= 'font-size:10pt;'>*Drives Majority<br>of Order Sales*</span>
      149:        <span style= 'font-size:12pt;'>**Secondary Item**</span><br>\n         <span style= 'font-size:10pt;'>*Product is an<br>Addon Item*</span>
      150:        <span style= 'font-size:12pt;'>**Trending Sales**</span><br>\n         <span style= 'font-size:10pt;'>*Recent Sales<br>shows Trend*</span>
      
      $pdata3
           product_sku restock category3          variable             value
        1:      141124      no   Edibles      has_oos_risk     Flag Assigned
        2:      141124      no   Edibles has_sales_decline     Flag Assigned
        3:      141124      no   Edibles  has_sales_growth Flag Not Assigned
        4:      141124      no   Edibles      is_long_term     Flag Assigned
        5:      141124      no   Edibles    is_new_on_menu Flag Not Assigned
       ---                                                                  
      122:      733615      no   Edibles    is_new_on_menu Flag Not Assigned
      123:      733615      no   Edibles     is_price_high Flag Not Assigned
      124:      733615      no   Edibles      is_price_low     Flag Assigned
      125:      733615      no   Edibles        is_primary Flag Not Assigned
      126:      733615      no   Edibles      is_secondary     Flag Assigned
                 pct pctlab
        1: 0.9333333    93%
        2: 0.2666667    27%
        3: 1.0000000   100%
        4: 0.5333333    53%
        5: 1.0000000   100%
       ---                 
      122: 1.0000000   100%
      123: 1.0000000   100%
      124: 0.3333333    33%
      125: 1.0000000   100%
      126: 0.2666667    27%
                                                                                                                                                     fac_var
        1:      <span style= 'font-size:12pt;'>**Stockout Risk**</span><br>\n         <span style= 'font-size:10pt;'>*Supply has<br>risk of Stockout*</span>
        2:          <span style= 'font-size:12pt;'>**Sales Decline**</span><br>\n         <span style= 'font-size:10pt;'>*Sales Trend<br>is Negative*</span>
        3:           <span style= 'font-size:12pt;'>**Sales Growth**</span><br>\n         <span style= 'font-size:10pt;'>*Sales Trend<br>is Positive*</span>
        4:               <span style= 'font-size:12pt;'>**Menu Classic**</span><br>\n         <span style= 'font-size:10pt;'>*Long-Term<br>Menu Item*</span>
        5:            <span style= 'font-size:12pt;'>**New Product**</span><br>\n         <span style= 'font-size:10pt;'>*Recent Addition<br>on Menu*</span>
       ---                                                                                                                                                  
      122:            <span style= 'font-size:12pt;'>**New Product**</span><br>\n         <span style= 'font-size:10pt;'>*Recent Addition<br>on Menu*</span>
      123:      <span style= 'font-size:12pt;'>**Top Shelf**</span><br>\n         <span style= 'font-size:10pt;'>*High Price<br>Relative to Category*</span>
      124:    <span style= 'font-size:12pt;'>**Bottom Shelf**</span><br>\n         <span style= 'font-size:10pt;'>*Low Price<br>Relative to Category*</span>
      125: <span style= 'font-size:12pt;'>**Primary Product**</span><br>\n         <span style= 'font-size:10pt;'>*Drives Majority<br>of Order Sales*</span>
      126:        <span style= 'font-size:12pt;'>**Secondary Item**</span><br>\n         <span style= 'font-size:10pt;'>*Product is an<br>Addon Item*</span>
                 value2
        1:     Assigned
        2:     Assigned
        3: Not Assigned
        4:     Assigned
        5: Not Assigned
       ---             
      122: Not Assigned
      123: Not Assigned
      124:     Assigned
      125: Not Assigned
      126:     Assigned
      
      $pdata4
          product_sku product_trait
       1:      141124   sales_trend
       2:      141124   supply_risk
       3:      141124   price_point
       4:      141124   order_spend
       5:      141124   menu_staple
       6:      161976   sales_trend
       7:      161976   supply_risk
       8:      161976   price_point
       9:      161976   order_spend
      10:      161976   menu_staple
      11:      186887   sales_trend
      12:      186887   supply_risk
      13:      186887   price_point
      14:      186887   order_spend
      15:      186887   menu_staple
      16:      186889   sales_trend
      17:      186889   supply_risk
      18:      186889   price_point
      19:      186889   order_spend
      20:      186889   menu_staple
      21:      188608   sales_trend
      22:      188608   supply_risk
      23:      188608   price_point
      24:      188608   order_spend
      25:      188608   menu_staple
      26:      242186   sales_trend
      27:      242186   supply_risk
      28:      242186   price_point
      29:      242186   order_spend
      30:      242186   menu_staple
      31:      359476   sales_trend
      32:      359476   supply_risk
      33:      359476   price_point
      34:      359476   order_spend
      35:      359476   menu_staple
      36:      487782   sales_trend
      37:      487782   supply_risk
      38:      487782   price_point
      39:      487782   order_spend
      40:      487782   menu_staple
      41:      487784   sales_trend
      42:      487784   supply_risk
      43:      487784   price_point
      44:      487784   order_spend
      45:      487784   menu_staple
      46:      606354   sales_trend
      47:      606354   supply_risk
      48:      606354   price_point
      49:      606354   order_spend
      50:      606354   menu_staple
      51:      733611   sales_trend
      52:      733611   supply_risk
      53:      733611   price_point
      54:      733611   order_spend
      55:      733611   menu_staple
      56:      733613   sales_trend
      57:      733613   supply_risk
      58:      733613   price_point
      59:      733613   order_spend
      60:      733613   menu_staple
      61:      733614   sales_trend
      62:      733614   supply_risk
      63:      733614   price_point
      64:      733614   order_spend
      65:      733614   menu_staple
      66:      733615   sales_trend
      67:      733615   supply_risk
      68:      733615   price_point
      69:      733615   order_spend
      70:      733615   menu_staple
          product_sku product_trait
                                                                  description restock
       1:                                  Recent sales are trending downward      no
       2:         Based on historical data, product supply is highly volatile      no
       3:             Price point is within the average of others in category      no
       4:                      Product is neither a primary or secondary item      no
       5:       Product is a long-term menu item (first sold +6 months prior)      no
       6:                            No statistically significant sales trend      no
       7:         Based on historical data, product supply is highly volatile      no
       8:             Price point is within the average of others in category      no
       9:                      Product is neither a primary or secondary item      no
      10:  Product isn't a new menu offering, nor is it a long-term menu item      no
      11:                            No statistically significant sales trend     yes
      12:         Based on historical data, product supply is highly volatile     yes
      13:             Price point is within the average of others in category     yes
      14:                      Product is neither a primary or secondary item     yes
      15:       Product is a long-term menu item (first sold +6 months prior)     yes
      16:                                  Recent sales are trending downward      no
      17:         Based on historical data, product supply is highly volatile      no
      18:             Price point is within the average of others in category      no
      19:                      Product is neither a primary or secondary item      no
      20:       Product is a long-term menu item (first sold +6 months prior)      no
      21:                                  Recent sales are trending downward      no
      22:         Based on historical data, product supply is highly volatile      no
      23:             Price point is within the average of others in category      no
      24:                      Product is neither a primary or secondary item      no
      25:       Product is a long-term menu item (first sold +6 months prior)      no
      26:                            No statistically significant sales trend     yes
      27:         Based on historical data, product supply is highly volatile     yes
      28:             Price point is within the average of others in category     yes
      29:                      Product is neither a primary or secondary item     yes
      30:       Product is a long-term menu item (first sold +6 months prior)     yes
      31:                                  Recent sales are trending downward      no
      32:         Based on historical data, product supply is highly volatile      no
      33:             Price point is within the average of others in category      no
      34:                      Product is neither a primary or secondary item      no
      35:       Product is a long-term menu item (first sold +6 months prior)      no
      36:                            No statistically significant sales trend     yes
      37:         Based on historical data, product supply is highly volatile     yes
      38:             Price point is within the average of others in category     yes
      39:                      Product is neither a primary or secondary item     yes
      40:       Product is a long-term menu item (first sold +6 months prior)     yes
      41:                            No statistically significant sales trend     yes
      42:         Based on historical data, product supply is highly volatile     yes
      43:             Price point is within the average of others in category     yes
      44:                      Product is neither a primary or secondary item     yes
      45:       Product is a long-term menu item (first sold +6 months prior)     yes
      46:                            No statistically significant sales trend      no
      47:         Based on historical data, product supply is highly volatile      no
      48:             Price point is within the average of others in category      no
      49:                      Product is neither a primary or secondary item      no
      50:  Product isn't a new menu offering, nor is it a long-term menu item      no
      51:                            No statistically significant sales trend      no
      52:         Based on historical data, product supply is highly volatile      no
      53:                   Price point is low relative to others in category      no
      54: This product drives less than 25% of the order total when purchased      no
      55:  Product isn't a new menu offering, nor is it a long-term menu item      no
      56:                            No statistically significant sales trend      no
      57:         Based on historical data, product supply is highly volatile      no
      58:                   Price point is low relative to others in category      no
      59: This product drives less than 25% of the order total when purchased      no
      60:  Product isn't a new menu offering, nor is it a long-term menu item      no
      61:                            No statistically significant sales trend      no
      62:         Based on historical data, product supply is highly volatile      no
      63:                   Price point is low relative to others in category      no
      64: This product drives less than 25% of the order total when purchased      no
      65:  Product isn't a new menu offering, nor is it a long-term menu item      no
      66:                            No statistically significant sales trend      no
      67:         Based on historical data, product supply is highly volatile      no
      68:                   Price point is low relative to others in category      no
      69: This product drives less than 25% of the order total when purchased      no
      70:  Product isn't a new menu offering, nor is it a long-term menu item      no
                                                                  description restock
          category3
       1:   Edibles
       2:   Edibles
       3:   Edibles
       4:   Edibles
       5:   Edibles
       6:   Edibles
       7:   Edibles
       8:   Edibles
       9:   Edibles
      10:   Edibles
      11:   Edibles
      12:   Edibles
      13:   Edibles
      14:   Edibles
      15:   Edibles
      16:   Edibles
      17:   Edibles
      18:   Edibles
      19:   Edibles
      20:   Edibles
      21:   Edibles
      22:   Edibles
      23:   Edibles
      24:   Edibles
      25:   Edibles
      26:   Edibles
      27:   Edibles
      28:   Edibles
      29:   Edibles
      30:   Edibles
      31:   Edibles
      32:   Edibles
      33:   Edibles
      34:   Edibles
      35:   Edibles
      36:   Edibles
      37:   Edibles
      38:   Edibles
      39:   Edibles
      40:   Edibles
      41:   Edibles
      42:   Edibles
      43:   Edibles
      44:   Edibles
      45:   Edibles
      46:   Edibles
      47:   Edibles
      48:   Edibles
      49:   Edibles
      50:   Edibles
      51:   Edibles
      52:   Edibles
      53:   Edibles
      54:   Edibles
      55:   Edibles
      56:   Edibles
      57:   Edibles
      58:   Edibles
      59:   Edibles
      60:   Edibles
      61:   Edibles
      62:   Edibles
      63:   Edibles
      64:   Edibles
      65:   Edibles
      66:   Edibles
      67:   Edibles
      68:   Edibles
      69:   Edibles
      70:   Edibles
          category3
                                                                                                                                                                         lab
       1:                    <span style= 'font-size:12pt;'>**Sales Decline**</span><br>\n                <span style= 'font-size:10pt;'>*Sales are<br>trending down*</span>
       2:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
       3:      <span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>
       4: <span style= 'font-size:12pt;'>**Ave Order Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>
       5:                        <span style= 'font-size:12pt;'>**Menu Classic**</span><br>\n                <span style= 'font-size:10pt;'>*Long-term<br>menu items*</span>
       6:  <span style= 'font-size:12pt;'>**No Sales Trend**</span><br>\n                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>
       7:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
       8:      <span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>
       9: <span style= 'font-size:12pt;'>**Ave Order Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>
      10:       <span style= 'font-size:12pt;'>**Average History**</span><br>\n                <span style= 'font-size:10pt;'>*Product not new<br>nor a menu classic*</span>
      11:  <span style= 'font-size:12pt;'>**No Sales Trend**</span><br>\n                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>
      12:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      13:      <span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>
      14: <span style= 'font-size:12pt;'>**Ave Order Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>
      15:                        <span style= 'font-size:12pt;'>**Menu Classic**</span><br>\n                <span style= 'font-size:10pt;'>*Long-term<br>menu items*</span>
      16:                    <span style= 'font-size:12pt;'>**Sales Decline**</span><br>\n                <span style= 'font-size:10pt;'>*Sales are<br>trending down*</span>
      17:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      18:      <span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>
      19: <span style= 'font-size:12pt;'>**Ave Order Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>
      20:                        <span style= 'font-size:12pt;'>**Menu Classic**</span><br>\n                <span style= 'font-size:10pt;'>*Long-term<br>menu items*</span>
      21:                    <span style= 'font-size:12pt;'>**Sales Decline**</span><br>\n                <span style= 'font-size:10pt;'>*Sales are<br>trending down*</span>
      22:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      23:      <span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>
      24: <span style= 'font-size:12pt;'>**Ave Order Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>
      25:                        <span style= 'font-size:12pt;'>**Menu Classic**</span><br>\n                <span style= 'font-size:10pt;'>*Long-term<br>menu items*</span>
      26:  <span style= 'font-size:12pt;'>**No Sales Trend**</span><br>\n                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>
      27:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      28:      <span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>
      29: <span style= 'font-size:12pt;'>**Ave Order Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>
      30:                        <span style= 'font-size:12pt;'>**Menu Classic**</span><br>\n                <span style= 'font-size:10pt;'>*Long-term<br>menu items*</span>
      31:                    <span style= 'font-size:12pt;'>**Sales Decline**</span><br>\n                <span style= 'font-size:10pt;'>*Sales are<br>trending down*</span>
      32:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      33:      <span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>
      34: <span style= 'font-size:12pt;'>**Ave Order Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>
      35:                        <span style= 'font-size:12pt;'>**Menu Classic**</span><br>\n                <span style= 'font-size:10pt;'>*Long-term<br>menu items*</span>
      36:  <span style= 'font-size:12pt;'>**No Sales Trend**</span><br>\n                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>
      37:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      38:      <span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>
      39: <span style= 'font-size:12pt;'>**Ave Order Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>
      40:                        <span style= 'font-size:12pt;'>**Menu Classic**</span><br>\n                <span style= 'font-size:10pt;'>*Long-term<br>menu items*</span>
      41:  <span style= 'font-size:12pt;'>**No Sales Trend**</span><br>\n                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>
      42:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      43:      <span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>
      44: <span style= 'font-size:12pt;'>**Ave Order Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>
      45:                        <span style= 'font-size:12pt;'>**Menu Classic**</span><br>\n                <span style= 'font-size:10pt;'>*Long-term<br>menu items*</span>
      46:  <span style= 'font-size:12pt;'>**No Sales Trend**</span><br>\n                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>
      47:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      48:      <span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>
      49: <span style= 'font-size:12pt;'>**Ave Order Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>
      50:       <span style= 'font-size:12pt;'>**Average History**</span><br>\n                <span style= 'font-size:10pt;'>*Product not new<br>nor a menu classic*</span>
      51:  <span style= 'font-size:12pt;'>**No Sales Trend**</span><br>\n                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>
      52:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      53:                                <span style= 'font-size:12pt;'>**Bottom Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Low Priced Item*</span>
      54:           <span style= 'font-size:12pt;'>**Secondary Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are added<br>on to orders*</span>
      55:       <span style= 'font-size:12pt;'>**Average History**</span><br>\n                <span style= 'font-size:10pt;'>*Product not new<br>nor a menu classic*</span>
      56:  <span style= 'font-size:12pt;'>**No Sales Trend**</span><br>\n                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>
      57:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      58:                                <span style= 'font-size:12pt;'>**Bottom Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Low Priced Item*</span>
      59:           <span style= 'font-size:12pt;'>**Secondary Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are added<br>on to orders*</span>
      60:       <span style= 'font-size:12pt;'>**Average History**</span><br>\n                <span style= 'font-size:10pt;'>*Product not new<br>nor a menu classic*</span>
      61:  <span style= 'font-size:12pt;'>**No Sales Trend**</span><br>\n                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>
      62:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      63:                                <span style= 'font-size:12pt;'>**Bottom Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Low Priced Item*</span>
      64:           <span style= 'font-size:12pt;'>**Secondary Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are added<br>on to orders*</span>
      65:       <span style= 'font-size:12pt;'>**Average History**</span><br>\n                <span style= 'font-size:10pt;'>*Product not new<br>nor a menu classic*</span>
      66:  <span style= 'font-size:12pt;'>**No Sales Trend**</span><br>\n                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>
      67:                <span style= 'font-size:12pt;'>**Supply Risky**</span><br>\n                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>
      68:                                <span style= 'font-size:12pt;'>**Bottom Shelf**</span><br>\n                <span style= 'font-size:10pt;'>*Low Priced Item*</span>
      69:           <span style= 'font-size:12pt;'>**Secondary Item**</span><br>\n                <span style= 'font-size:10pt;'>*Products are added<br>on to orders*</span>
      70:       <span style= 'font-size:12pt;'>**Average History**</span><br>\n                <span style= 'font-size:10pt;'>*Product not new<br>nor a menu classic*</span>
                                                                                                                                                                         lab
      
      $data
      $data$recs
      $data$recs$results
          product_sku is_recommended restock
       1:      141124          FALSE      no
       2:      161976          FALSE      no
       3:      186887           TRUE     yes
       4:      186889          FALSE      no
       5:      188608          FALSE      no
       6:      242186           TRUE     yes
       7:      359476          FALSE      no
       8:      487782           TRUE     yes
       9:      487784           TRUE     yes
      10:      606354          FALSE      no
      11:      733611          FALSE      no
      12:      733613          FALSE      no
      13:      733614          FALSE      no
      14:      733615          FALSE      no
      15:      733616             NA  unsure
      
      $data$recs$meta
      $data$recs$meta$flags
          product_sku is_long_term is_new_on_menu is_primary is_secondary
       1:      141124         TRUE          FALSE      FALSE        FALSE
       2:      161976        FALSE          FALSE      FALSE        FALSE
       3:      186887         TRUE          FALSE      FALSE        FALSE
       4:      186889         TRUE          FALSE      FALSE        FALSE
       5:      188608         TRUE          FALSE      FALSE        FALSE
       6:      242186         TRUE          FALSE      FALSE        FALSE
       7:      359476         TRUE          FALSE      FALSE        FALSE
       8:      487782         TRUE          FALSE      FALSE        FALSE
       9:      487784         TRUE          FALSE      FALSE        FALSE
      10:      606354        FALSE          FALSE      FALSE        FALSE
      11:      733611        FALSE          FALSE      FALSE         TRUE
      12:      733613        FALSE          FALSE      FALSE         TRUE
      13:      733614        FALSE          FALSE      FALSE         TRUE
      14:      733615        FALSE          FALSE      FALSE         TRUE
      15:      733616        FALSE          FALSE      FALSE        FALSE
          has_oos_risk is_trending has_sales_growth has_sales_decline is_price_high
       1:         TRUE        TRUE            FALSE              TRUE         FALSE
       2:         TRUE       FALSE            FALSE             FALSE         FALSE
       3:         TRUE       FALSE            FALSE             FALSE         FALSE
       4:         TRUE        TRUE            FALSE              TRUE         FALSE
       5:         TRUE        TRUE            FALSE              TRUE         FALSE
       6:         TRUE       FALSE            FALSE             FALSE         FALSE
       7:         TRUE        TRUE            FALSE              TRUE         FALSE
       8:         TRUE       FALSE            FALSE             FALSE         FALSE
       9:         TRUE       FALSE            FALSE             FALSE         FALSE
      10:         TRUE       FALSE            FALSE             FALSE         FALSE
      11:         TRUE       FALSE            FALSE             FALSE         FALSE
      12:         TRUE       FALSE            FALSE             FALSE         FALSE
      13:         TRUE       FALSE            FALSE             FALSE         FALSE
      14:         TRUE       FALSE            FALSE             FALSE         FALSE
      15:        FALSE       FALSE            FALSE             FALSE         FALSE
          is_price_low
       1:        FALSE
       2:        FALSE
       3:        FALSE
       4:        FALSE
       5:        FALSE
       6:        FALSE
       7:        FALSE
       8:        FALSE
       9:        FALSE
      10:        FALSE
      11:         TRUE
      12:         TRUE
      13:         TRUE
      14:         TRUE
      15:         TRUE
      
      $data$recs$meta$stats
          product_sku days_since_first menu_period_days category3 cat_price_low
       1:      141124              762              735   Edibles            13
       2:      161976               66               52   Edibles            13
       3:      186887              628              569   Edibles            13
       4:      186889              630              575   Edibles            13
       5:      188608              621              607   Edibles            13
       6:      242186              479              453   Edibles            13
       7:      359476              310              296   Edibles            13
       8:      487782              230              216   Edibles            13
       9:      487784              229              214   Edibles            13
      10:      606354              151               89   Edibles            13
      11:      733611               74               59   Edibles            13
      12:      733613               74               60   Edibles            13
      13:      733614               73               59   Edibles            13
      14:      733615               73               59   Edibles            13
      15:      733616               74               58   Edibles            13
          cat_price_high tot_days tot_sales tot_units ave_unit_price std_unit_price
       1:             20       34   1468.00        84       17.76943       2.050045
       2:             20       28   1153.00        62       18.66071       1.831639
       3:             20       35   1548.00        87       17.96619       2.019061
       4:             20       15    492.00        29       17.11667       1.853729
       5:             20       33   1106.00        61       18.39899       1.996064
       6:             20       15    587.20        33       17.83111       1.669639
       7:             20       42   1332.00        72       18.47381       2.037475
       8:             20       41   1314.00        72       18.47154       1.954661
       9:             20       38   1153.00        63       18.43640       2.005383
      10:             20       13    326.00        18       18.15385       2.192645
      11:             20       43   1064.05        93       11.47581       1.318442
      12:             20       44    942.86        81       11.61697       1.598112
      13:             20       37    890.50        78       11.39801       1.370430
      14:             20       36    716.95        61       11.61424       1.317510
      15:             20       47   1449.50       121       12.01662       1.246836
          price_point share_of_order pct_oos_days days_sold days_not_sold oos_periods
       1:         mid      0.2608124    0.5000000        34            34           9
       2:         mid      0.2661259    0.4615385        28            24           5
       3:         mid      0.2616921    0.3000000        35            15          13
       4:         mid      0.2312468    0.7222222        15            39          12
       5:         mid      0.2774332    0.6489362        33            61          13
       6:         mid      0.2424406    0.5588235        15            19           7
       7:         mid      0.2567489    0.5578947        42            53          17
       8:         mid      0.3003895    0.4938272        41            40          12
       9:         mid      0.2922508    0.5869565        38            54          16
      10:         mid      0.2954252    0.7234043        13            34           6
      11:         low      0.1819845    0.2833333        43            17          13
      12:         low      0.1664511    0.2786885        44            17          12
      13:         low      0.1856103    0.3833333        37            23          18
      14:         low      0.1753730    0.4000000        36            24          14
      15:         low      0.2023344    0.2033898        47            12          10
          ave_oos_period_days mean_past mean_recent stdev_pooled
       1:           2.7777778  47.07143    25.00000    12.046005
       2:           3.8000000  38.09091    52.50000    15.403252
       3:           0.1538462  46.65517    32.50000     9.853347
       4:           2.2500000  40.88889    20.66667     9.886344
       5:           3.6923077  36.48148    20.16667     8.463758
       6:           1.7142857  45.00000    30.36667    10.757261
       7:           2.1176471  33.94444    18.33333     9.226794
       8:           2.3333333  32.54286    29.16667     6.834073
       9:           2.3750000  31.18750    25.83333     6.687867
      10:           4.6666667  28.57143    21.00000     5.003524
      11:           0.3076923  25.85946    17.87500     7.473909
      12:           0.4166667  22.40026    15.27500     4.586561
      13:           0.2777778  23.12742    28.92500     7.640881
      14:           0.7142857  19.21833    23.40000     5.585589
      15:           0.2000000  31.61220    25.56667    10.477045
      
      $data$recs$meta$descr
          product_sku product_trait
       1:      141124   sales_trend
       2:      141124   supply_risk
       3:      141124   price_point
       4:      141124   order_spend
       5:      141124   menu_staple
       6:      161976   sales_trend
       7:      161976   supply_risk
       8:      161976   price_point
       9:      161976   order_spend
      10:      161976   menu_staple
      11:      186887   sales_trend
      12:      186887   supply_risk
      13:      186887   price_point
      14:      186887   order_spend
      15:      186887   menu_staple
      16:      186889   sales_trend
      17:      186889   supply_risk
      18:      186889   price_point
      19:      186889   order_spend
      20:      186889   menu_staple
      21:      188608   sales_trend
      22:      188608   supply_risk
      23:      188608   price_point
      24:      188608   order_spend
      25:      188608   menu_staple
      26:      242186   sales_trend
      27:      242186   supply_risk
      28:      242186   price_point
      29:      242186   order_spend
      30:      242186   menu_staple
      31:      359476   sales_trend
      32:      359476   supply_risk
      33:      359476   price_point
      34:      359476   order_spend
      35:      359476   menu_staple
      36:      487782   sales_trend
      37:      487782   supply_risk
      38:      487782   price_point
      39:      487782   order_spend
      40:      487782   menu_staple
      41:      487784   sales_trend
      42:      487784   supply_risk
      43:      487784   price_point
      44:      487784   order_spend
      45:      487784   menu_staple
      46:      606354   sales_trend
      47:      606354   supply_risk
      48:      606354   price_point
      49:      606354   order_spend
      50:      606354   menu_staple
      51:      733611   sales_trend
      52:      733611   supply_risk
      53:      733611   price_point
      54:      733611   order_spend
      55:      733611   menu_staple
      56:      733613   sales_trend
      57:      733613   supply_risk
      58:      733613   price_point
      59:      733613   order_spend
      60:      733613   menu_staple
      61:      733614   sales_trend
      62:      733614   supply_risk
      63:      733614   price_point
      64:      733614   order_spend
      65:      733614   menu_staple
      66:      733615   sales_trend
      67:      733615   supply_risk
      68:      733615   price_point
      69:      733615   order_spend
      70:      733615   menu_staple
      71:      733616   sales_trend
      72:      733616   supply_risk
      73:      733616   price_point
      74:      733616   order_spend
      75:      733616   menu_staple
          product_sku product_trait
                                                                  description
       1:                                  Recent sales are trending downward
       2:         Based on historical data, product supply is highly volatile
       3:             Price point is within the average of others in category
       4:                      Product is neither a primary or secondary item
       5:       Product is a long-term menu item (first sold +6 months prior)
       6:                            No statistically significant sales trend
       7:         Based on historical data, product supply is highly volatile
       8:             Price point is within the average of others in category
       9:                      Product is neither a primary or secondary item
      10:  Product isn't a new menu offering, nor is it a long-term menu item
      11:                            No statistically significant sales trend
      12:         Based on historical data, product supply is highly volatile
      13:             Price point is within the average of others in category
      14:                      Product is neither a primary or secondary item
      15:       Product is a long-term menu item (first sold +6 months prior)
      16:                                  Recent sales are trending downward
      17:         Based on historical data, product supply is highly volatile
      18:             Price point is within the average of others in category
      19:                      Product is neither a primary or secondary item
      20:       Product is a long-term menu item (first sold +6 months prior)
      21:                                  Recent sales are trending downward
      22:         Based on historical data, product supply is highly volatile
      23:             Price point is within the average of others in category
      24:                      Product is neither a primary or secondary item
      25:       Product is a long-term menu item (first sold +6 months prior)
      26:                            No statistically significant sales trend
      27:         Based on historical data, product supply is highly volatile
      28:             Price point is within the average of others in category
      29:                      Product is neither a primary or secondary item
      30:       Product is a long-term menu item (first sold +6 months prior)
      31:                                  Recent sales are trending downward
      32:         Based on historical data, product supply is highly volatile
      33:             Price point is within the average of others in category
      34:                      Product is neither a primary or secondary item
      35:       Product is a long-term menu item (first sold +6 months prior)
      36:                            No statistically significant sales trend
      37:         Based on historical data, product supply is highly volatile
      38:             Price point is within the average of others in category
      39:                      Product is neither a primary or secondary item
      40:       Product is a long-term menu item (first sold +6 months prior)
      41:                            No statistically significant sales trend
      42:         Based on historical data, product supply is highly volatile
      43:             Price point is within the average of others in category
      44:                      Product is neither a primary or secondary item
      45:       Product is a long-term menu item (first sold +6 months prior)
      46:                            No statistically significant sales trend
      47:         Based on historical data, product supply is highly volatile
      48:             Price point is within the average of others in category
      49:                      Product is neither a primary or secondary item
      50:  Product isn't a new menu offering, nor is it a long-term menu item
      51:                            No statistically significant sales trend
      52:         Based on historical data, product supply is highly volatile
      53:                   Price point is low relative to others in category
      54: This product drives less than 25% of the order total when purchased
      55:  Product isn't a new menu offering, nor is it a long-term menu item
      56:                            No statistically significant sales trend
      57:         Based on historical data, product supply is highly volatile
      58:                   Price point is low relative to others in category
      59: This product drives less than 25% of the order total when purchased
      60:  Product isn't a new menu offering, nor is it a long-term menu item
      61:                            No statistically significant sales trend
      62:         Based on historical data, product supply is highly volatile
      63:                   Price point is low relative to others in category
      64: This product drives less than 25% of the order total when purchased
      65:  Product isn't a new menu offering, nor is it a long-term menu item
      66:                            No statistically significant sales trend
      67:         Based on historical data, product supply is highly volatile
      68:                   Price point is low relative to others in category
      69: This product drives less than 25% of the order total when purchased
      70:  Product isn't a new menu offering, nor is it a long-term menu item
      71:                            No statistically significant sales trend
      72:     Based on historical data, product has limited to no supply risk
      73:                   Price point is low relative to others in category
      74:                      Product is neither a primary or secondary item
      75:  Product isn't a new menu offering, nor is it a long-term menu item
                                                                  description
      
      
      $data$recs$created_utc
      [1] "2023-12-06 00:22:30 UTC"
      
      $data$recs$status_code
      [1] 200
      
      $data$recs$status_msg
      [1] "All Skus Processed Ok"
      
      
      

# Utils - Handling Model Params

    Code
      ll
    Output
      $ml_npom
      [1] 14
      
      $ml_ltmi
      [1] 182
      
      $ml_secd
      [1] 20
      
      $ml_prim
      [1] 45
      
      $ml_ppql
      [1] 20
      
      $ml_ppqh
      [1] 80
      
      $ml_pair_ttest
      [1] FALSE
      
      $ml_pooled_var
      [1] TRUE
      
      $ml_trend_pval
      [1] 5
      
      $ml_trend_conf
      [1] 85
      
      $ml_stock_pval
      [1] 5
      
      $ml_stock_conf
      [1] 85
      

# Utils - Build and Save ML Context

    Code
      x
    Output
      $org_uuid
      [1] "2b0bfddc-d6c1-4c6d-909f-8571ac860846"
      
      $store_uuid
      [1] "ece69929-96e3-4ed8-9ddb-cc56749a0e23"
      
      $products
      $products[[1]]
          Sepal.Length Sepal.Width Petal.Length Petal.Width    Species
      1            5.1         3.5          1.4         0.2     setosa
      2            4.9         3.0          1.4         0.2     setosa
      3            4.7         3.2          1.3         0.2     setosa
      4            4.6         3.1          1.5         0.2     setosa
      5            5.0         3.6          1.4         0.2     setosa
      6            5.4         3.9          1.7         0.4     setosa
      7            4.6         3.4          1.4         0.3     setosa
      8            5.0         3.4          1.5         0.2     setosa
      9            4.4         2.9          1.4         0.2     setosa
      10           4.9         3.1          1.5         0.1     setosa
      11           5.4         3.7          1.5         0.2     setosa
      12           4.8         3.4          1.6         0.2     setosa
      13           4.8         3.0          1.4         0.1     setosa
      14           4.3         3.0          1.1         0.1     setosa
      15           5.8         4.0          1.2         0.2     setosa
      16           5.7         4.4          1.5         0.4     setosa
      17           5.4         3.9          1.3         0.4     setosa
      18           5.1         3.5          1.4         0.3     setosa
      19           5.7         3.8          1.7         0.3     setosa
      20           5.1         3.8          1.5         0.3     setosa
      21           5.4         3.4          1.7         0.2     setosa
      22           5.1         3.7          1.5         0.4     setosa
      23           4.6         3.6          1.0         0.2     setosa
      24           5.1         3.3          1.7         0.5     setosa
      25           4.8         3.4          1.9         0.2     setosa
      26           5.0         3.0          1.6         0.2     setosa
      27           5.0         3.4          1.6         0.4     setosa
      28           5.2         3.5          1.5         0.2     setosa
      29           5.2         3.4          1.4         0.2     setosa
      30           4.7         3.2          1.6         0.2     setosa
      31           4.8         3.1          1.6         0.2     setosa
      32           5.4         3.4          1.5         0.4     setosa
      33           5.2         4.1          1.5         0.1     setosa
      34           5.5         4.2          1.4         0.2     setosa
      35           4.9         3.1          1.5         0.2     setosa
      36           5.0         3.2          1.2         0.2     setosa
      37           5.5         3.5          1.3         0.2     setosa
      38           4.9         3.6          1.4         0.1     setosa
      39           4.4         3.0          1.3         0.2     setosa
      40           5.1         3.4          1.5         0.2     setosa
      41           5.0         3.5          1.3         0.3     setosa
      42           4.5         2.3          1.3         0.3     setosa
      43           4.4         3.2          1.3         0.2     setosa
      44           5.0         3.5          1.6         0.6     setosa
      45           5.1         3.8          1.9         0.4     setosa
      46           4.8         3.0          1.4         0.3     setosa
      47           5.1         3.8          1.6         0.2     setosa
      48           4.6         3.2          1.4         0.2     setosa
      49           5.3         3.7          1.5         0.2     setosa
      50           5.0         3.3          1.4         0.2     setosa
      51           7.0         3.2          4.7         1.4 versicolor
      52           6.4         3.2          4.5         1.5 versicolor
      53           6.9         3.1          4.9         1.5 versicolor
      54           5.5         2.3          4.0         1.3 versicolor
      55           6.5         2.8          4.6         1.5 versicolor
      56           5.7         2.8          4.5         1.3 versicolor
      57           6.3         3.3          4.7         1.6 versicolor
      58           4.9         2.4          3.3         1.0 versicolor
      59           6.6         2.9          4.6         1.3 versicolor
      60           5.2         2.7          3.9         1.4 versicolor
      61           5.0         2.0          3.5         1.0 versicolor
      62           5.9         3.0          4.2         1.5 versicolor
      63           6.0         2.2          4.0         1.0 versicolor
      64           6.1         2.9          4.7         1.4 versicolor
      65           5.6         2.9          3.6         1.3 versicolor
      66           6.7         3.1          4.4         1.4 versicolor
      67           5.6         3.0          4.5         1.5 versicolor
      68           5.8         2.7          4.1         1.0 versicolor
      69           6.2         2.2          4.5         1.5 versicolor
      70           5.6         2.5          3.9         1.1 versicolor
      71           5.9         3.2          4.8         1.8 versicolor
      72           6.1         2.8          4.0         1.3 versicolor
      73           6.3         2.5          4.9         1.5 versicolor
      74           6.1         2.8          4.7         1.2 versicolor
      75           6.4         2.9          4.3         1.3 versicolor
      76           6.6         3.0          4.4         1.4 versicolor
      77           6.8         2.8          4.8         1.4 versicolor
      78           6.7         3.0          5.0         1.7 versicolor
      79           6.0         2.9          4.5         1.5 versicolor
      80           5.7         2.6          3.5         1.0 versicolor
      81           5.5         2.4          3.8         1.1 versicolor
      82           5.5         2.4          3.7         1.0 versicolor
      83           5.8         2.7          3.9         1.2 versicolor
      84           6.0         2.7          5.1         1.6 versicolor
      85           5.4         3.0          4.5         1.5 versicolor
      86           6.0         3.4          4.5         1.6 versicolor
      87           6.7         3.1          4.7         1.5 versicolor
      88           6.3         2.3          4.4         1.3 versicolor
      89           5.6         3.0          4.1         1.3 versicolor
      90           5.5         2.5          4.0         1.3 versicolor
      91           5.5         2.6          4.4         1.2 versicolor
      92           6.1         3.0          4.6         1.4 versicolor
      93           5.8         2.6          4.0         1.2 versicolor
      94           5.0         2.3          3.3         1.0 versicolor
      95           5.6         2.7          4.2         1.3 versicolor
      96           5.7         3.0          4.2         1.2 versicolor
      97           5.7         2.9          4.2         1.3 versicolor
      98           6.2         2.9          4.3         1.3 versicolor
      99           5.1         2.5          3.0         1.1 versicolor
      100          5.7         2.8          4.1         1.3 versicolor
      101          6.3         3.3          6.0         2.5  virginica
      102          5.8         2.7          5.1         1.9  virginica
      103          7.1         3.0          5.9         2.1  virginica
      104          6.3         2.9          5.6         1.8  virginica
      105          6.5         3.0          5.8         2.2  virginica
      106          7.6         3.0          6.6         2.1  virginica
      107          4.9         2.5          4.5         1.7  virginica
      108          7.3         2.9          6.3         1.8  virginica
      109          6.7         2.5          5.8         1.8  virginica
      110          7.2         3.6          6.1         2.5  virginica
      111          6.5         3.2          5.1         2.0  virginica
      112          6.4         2.7          5.3         1.9  virginica
      113          6.8         3.0          5.5         2.1  virginica
      114          5.7         2.5          5.0         2.0  virginica
      115          5.8         2.8          5.1         2.4  virginica
      116          6.4         3.2          5.3         2.3  virginica
      117          6.5         3.0          5.5         1.8  virginica
      118          7.7         3.8          6.7         2.2  virginica
      119          7.7         2.6          6.9         2.3  virginica
      120          6.0         2.2          5.0         1.5  virginica
      121          6.9         3.2          5.7         2.3  virginica
      122          5.6         2.8          4.9         2.0  virginica
      123          7.7         2.8          6.7         2.0  virginica
      124          6.3         2.7          4.9         1.8  virginica
      125          6.7         3.3          5.7         2.1  virginica
      126          7.2         3.2          6.0         1.8  virginica
      127          6.2         2.8          4.8         1.8  virginica
      128          6.1         3.0          4.9         1.8  virginica
      129          6.4         2.8          5.6         2.1  virginica
      130          7.2         3.0          5.8         1.6  virginica
      131          7.4         2.8          6.1         1.9  virginica
      132          7.9         3.8          6.4         2.0  virginica
      133          6.4         2.8          5.6         2.2  virginica
      134          6.3         2.8          5.1         1.5  virginica
      135          6.1         2.6          5.6         1.4  virginica
      136          7.7         3.0          6.1         2.3  virginica
      137          6.3         3.4          5.6         2.4  virginica
      138          6.4         3.1          5.5         1.8  virginica
      139          6.0         3.0          4.8         1.8  virginica
      140          6.9         3.1          5.4         2.1  virginica
      141          6.7         3.1          5.6         2.4  virginica
      142          6.9         3.1          5.1         2.3  virginica
      143          5.8         2.7          5.1         1.9  virginica
      144          6.8         3.2          5.9         2.3  virginica
      145          6.7         3.3          5.7         2.5  virginica
      146          6.7         3.0          5.2         2.3  virginica
      147          6.3         2.5          5.0         1.9  virginica
      148          6.5         3.0          5.2         2.0  virginica
      149          6.2         3.4          5.4         2.3  virginica
      150          5.9         3.0          5.1         1.8  virginica
      
      
      $model
      $model$ml_npom
      [1] 14
      
      $model$ml_ltmi
      [1] 182
      
      $model$ml_secd
      [1] 0.2
      
      $model$ml_prim
      [1] 0.45
      
      $model$ml_ppql
      [1] 0.2
      
      $model$ml_ppqh
      [1] 0.8
      
      $model$ml_pair_ttest
      [1] FALSE
      
      $model$ml_pooled_var
      [1] TRUE
      
      $model$ml_trend_pval
      [1] 0.05
      
      $model$ml_trend_conf
      [1] 0.85
      
      $model$ml_stock_pval
      [1] 0.05
      
      $model$ml_stock_conf
      [1] 0.85
      
      

