#%%
# https://ndlib.readthedocs.io/en/latest/reference/models/epidemics/SIS.html?highlight=SISModel

import networkx as nx
import ndlib.models.ModelConfig as mc
import ndlib.models.epidemics.SISModel as sis

# Network topology
g = nx.erdos_renyi_graph(1000, 0.1)

# Model selection
model = sis.SISModel(g)

# Model Configuration
cfg = mc.Configuration()
cfg.add_model_parameter('beta', 0.01)
cfg.add_model_parameter('lambda', 0.005)
cfg.add_model_parameter("fraction_infected", 0.05)
model.set_initial_status(cfg)

#%%
# Simulation
iterations = model.iteration_bunch(200)
trends = model.build_trends(iterations)
from bokeh.io import output_notebook, show
from ndlib.viz.bokeh.DiffusionTrend import DiffusionTrend
viz = DiffusionTrend(model, trends)
p = viz.plot(width=400, height=400)
# show(p)
from ndlib.viz.bokeh.DiffusionPrevalence import DiffusionPrevalence
viz2 = DiffusionPrevalence(model, trends)
p2 = viz2.plot(width=400, height=400)
# show(p2)
from ndlib.viz.bokeh.MultiPlot import MultiPlot
vm = MultiPlot()
vm.add_plot(p)
vm.add_plot(p2)
m = vm.plot()
show(m)
#%%
