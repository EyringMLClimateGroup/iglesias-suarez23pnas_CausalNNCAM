import matplotlib.pyplot as plt
from tigramite import plotting as tp
import numpy as np


def plot_links(link_matrix,
               links,
               var_names,
               val_matrix = None,
               save_name = None,
               figsize = (16, 16),
               node_size = 0.15
              ):
    """
    This function is copied from the basic tutorial, but it may not be
    generalizable: It had issues with output from pcmciplus
    """

    var_names = np.array(var_names)
    
    linked_variables = set() # Avoids duplicates and sorts when list
    for child, parents_list in links.items():
        if len(parents_list) > 0:
            linked_variables.add(child)
            for parent in parents_list:
                linked_variables.add(parent[0])
    
    if len(linked_variables) != 0:
        linked_variables = list(linked_variables)
        # Raise an exception if there is a different number of links
        # on the reduced link_matrix
        filtered_link_matrix = link_matrix[linked_variables][:,linked_variables]
        assert((link_matrix == True).sum()
               == (filtered_link_matrix == True).sum())
        var_names = var_names[linked_variables]
        if val_matrix is not None:
            val_matrix = val_matrix[linked_variables][:,linked_variables]
    else:
        filtered_link_matrix = link_matrix
    
    tp.plot_graph(
        figsize = figsize,
        val_matrix = val_matrix,
        link_matrix = filtered_link_matrix,
        var_names = var_names,
        link_colorbar_label = 'cross-MCI',
        node_colorbar_label = 'auto-MCI',
        arrow_linewidth = 5,
        node_size = node_size,
        save_name = save_name,
        show_colorbar = False
    ); plt.show()