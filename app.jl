using Dash, DashHtmlComponents, DashCoreComponents, HTTP, CSV, Dates, Printf

r = HTTP.request("GET", "https://finance.yahoo.com/quote/AMZN/history?p=AMZN");
crumb = match(r"(?:CrumbStore\"\:\{\"crumb\":\")(.*?)(?:\")", String(r.body)).captures;
session_cookie = match(r"(?:B=)(.*?)(?:;)", HTTP.header(r, "Set-Cookie")).captures;

app = dash();

app.layout = html_div(style=Dict("width"=>"500")) do
    dcc_dropdown(
        id="stock-dropdown",
        options=[
            (label="Coke", value="COKE"), 
            (label="Tesla", value="TSLA"), 
            (label="Apple", value="AAPL")
        ],
        value="COKE"
    ),
    dcc_graph(id="stock-graph")
end;

callback!(app,
    Output("stock-graph", "figure"),
    Input("stock-dropdown", "value")
    ) do ticker
        today = @sprintf("%i", datetime2unix(Dates.now()))
        url = string("https://query1.finance.yahoo.com/v7/finance/download/", 
                     ticker, "?period1=1167609600&period2=", today, "&interval=1d&events=history&crumb=", crumb[1])
        results = HTTP.request("GET", url, Dict("B"=>session_cookie[1]))
        df = CSV.read(IOBuffer(String(results.body)));
    return (data=[(x=df[:,"Date"], y=df[:,"Close"])], 
            layout=(margin=[(l=40, r=0, t=20, b=30)],
                    title=ticker))
end;

run_server(app)
