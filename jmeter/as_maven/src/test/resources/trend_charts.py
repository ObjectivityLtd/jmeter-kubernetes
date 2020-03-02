import pandas as pd
import plotly.graph_objects as go
import plotly.io as pio
import logging

colnames = ['timeStamp','elapsed','label','responseCode','responseMessage','threadName','dataType','success','failureMessage','bytes','sentBytes','grpThreads','allThreads','URL','Latency','IdleTime','Connect']
result_files = ["23.csv"]
fig = go.Figure()

for result_file in result_files:
    try:
        df = pd.read_csv("tmp/%s" % result_file, names=colnames)
        print df.elapsed.tolist()
        print df.timeStamp.tolist()
        fig.add_trace(go.Scatter(x=df.timeStamp.tolist()[1:-1], y=df.elapsed.tolist(), mode='lines+markers', showlegend=True,name=result_file))
    except Exception as e:
        logging.error(e)

#threshold = 4000
#fig.add_trace(go.Scatter(y = [threshold for sample in df.times.tolist()[1:-1]], x=df.id.tolist(), mode='lines+markers', showlegend=True,name="Expectation - %s ms" % threshold))
fig.update_layout(title_text='Search Response Times [ms ]during substantial user load',
                  xaxis_title='Search Number',
                  yaxis_title='Search Time [ms]')

pio.write_html(fig, file='tmp/23_hello_world.html', auto_open=True)