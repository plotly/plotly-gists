library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
library(quantmod)

getSymbols(c("Coke" = "COKE", "Tesla" = "TSLA", "Apple" = "AAPL"))

app <- Dash$new()

app$layout(
    htmlDiv(
        list(
            dccDropdown(
                id = "stock-dropdown",
                options = list(
                    list(label = "Coke", value = "COKE"),
                    list(label = "Tesla", value = "TSLA"),
                    list(label = "Apple", value = "AAPL")
                    ),
                value = "COKE"
            ),
            dccGraph(id = "stock-graph")
        )
    )
)

app$callback(output("stock-graph", "figure"),
             list(input("stock-dropdown", "value")),
             function(ticker) {
               d <- switch(ticker, AAPL = AAPL, TSLA = TSLA, COKE = COKE)
               list(
                 data = list(
                   list(x = index(d), y = as.numeric(d[, 4]))
                   ),
                 layout = list(title = ticker)
               )
              }
)

app$run_server()
