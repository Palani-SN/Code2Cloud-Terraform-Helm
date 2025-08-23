from LogExAn.LogicalAnalyser import LogAn
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import hashlib


class Logic_Map:

    cond_list = []

    def __init__(self, condition):

        cond = condition.replace(" ", "")
        hash_name = hashlib.md5(cond.encode("utf8")).hexdigest()
        if(hash_name in Logic_Map.cond_list):
            self.filename = f"static/img/{hash_name}"
        else:
            # condition = "( ( Var_new_8 < 8 && Var_new_8 > 1 && Var_new_1 < 8 && Var_new_1 > 1) || ( ( Var_new_1 == 1 && Var_new_2 == 2 && Var_new_3 == 3 && Var_new_4 == 4 ) || ( Var_new_5 == 5 && Var_new_6 == 6 && Var_new_7 == 7 && Var_new_8 == 8 ) ) )"
            LA = LogAn(condition)
            result = LA.solution('DICT')
            max_len, transformed = self.transform_data(result)
            qrates, norm, valfmt = self.setup_LogicMap()
            fig = plt.figure()
            fig.set_figheight(1.5 * len(transformed))
            fig.set_figwidth(max_len)
            for i in range(len(transformed)):
                ax = plt.subplot2grid(shape=(len(transformed), max_len), loc=(
                    i, 0), colspan=len(transformed[i]['data']))
                self.create_LogicMap(ax, transformed[i]['data'], transformed[i]
                                     ['var_name'], transformed[i]['var_values'], qrates, norm, valfmt)
            self.filename = f"static/img/{hash_name}"
            self.teardown_LogicMap(self.filename)

    def transform_data(self, result):

        keys = sorted(
            list(set(list(result["True"].keys())+list(result["False"].keys()))))
        heatmap_inputs = []
        len_lst = []
        for x in keys:
            heatmap_input = {}
            heatmap_input["var_name"] = x
            heatmap_input["var_values"] = sorted(
                result["True"][x]+result["False"][x])
            len_lst.append(len(heatmap_input["var_values"]))
            heatmap_input["data"] = []
            for y in heatmap_input["var_values"]:
                if y in result["True"][x]:
                    heatmap_input["data"].append(1)
                elif y in result["False"][x]:
                    heatmap_input["data"].append(-1)
                else:
                    heatmap_input["data"].append(0)
            heatmap_inputs.append(heatmap_input)

        return max(len_lst), heatmap_inputs

    def setup_LogicMap(self, quality_rates="PPOFF"):
        qrates = list(quality_rates)
        linspace = np.linspace(-3.5, 3.5, len(qrates)+1)
        norm = matplotlib.colors.BoundaryNorm(linspace, len(qrates))
        qrates_mod = qrates[::-1]
        def norm_x(x, pos): return qrates_mod[norm(x)]
        valfmt = matplotlib.ticker.FuncFormatter(norm_x)

        return qrates, norm, valfmt

    def create_LogicMap(self, ax, data, var_name, var_values, qrates, norm, valfmt):

        if(len(data) == len(var_values)):
            data = np.array([data])
            row_labels = [var_name]
            col_labels = var_values

            im = ax.imshow(data, cmap=plt.get_cmap(
                "PiYG", len(qrates)), norm=norm)

            ax.set_xticks(np.arange(data.shape[1]), labels=col_labels)
            ax.set_yticks(np.arange(data.shape[0]), labels=row_labels)

            # Let the horizontal axes labeling appear on top.
            ax.tick_params(top=True, bottom=False,
                           labeltop=True, labelbottom=False)

            # Turn spines off and create white grid.
            ax.spines[:].set_visible(False)

            ax.set_xticks(np.arange(data.shape[1]+1)-.5, minor=True)
            ax.set_yticks(np.arange(data.shape[0]+1)-.5, minor=True)
            ax.grid(which="minor", color="w", linestyle='-', linewidth=3)
            ax.tick_params(which="minor", bottom=False, left=False)

            kw = dict(horizontalalignment="center",
                      verticalalignment="center",
                      size=12,
                      fontweight='bold'
                      )

            # Get the formatter in case a string is supplied
            if isinstance(valfmt, str):
                valfmt = matplotlib.ticker.StrMethodFormatter(valfmt)

            textcolors = ("white", "black")
            for j in range(data.shape[1]):
                kw.update(color=textcolors[int(data[0, j] == 0)])
                text = im.axes.text(j, 0, valfmt(data[0, j], None), **kw)

        else:
            assert 0, "len(data) != len(var_values) check the length of the inputs"

    def teardown_LogicMap(self, filename=None):

        if(filename):
            plt.tight_layout()
            plt.savefig(f'{filename}.jpg')
        else:
            plt.tight_layout()
            plt.show()


if __name__ == '__main__':

    LM = Logic_Map("( ( Var_new_8 < 8 && Var_new_8 > 1 && Var_new_1 < 8 && Var_new_1 > 1) || ( ( Var_new_1 == 1 && Var_new_2 == 2 && Var_new_3 == 3 && Var_new_4 == 4 ) || ( Var_new_5 == 5 && Var_new_6 == 6 && Var_new_7 == 7 && Var_new_8 == 8 ) ) )")
    print(LM.filename)

    # LM = Logic_Map(" ( var1 == 1 && var2 == 2 && var3 == 3 && var4 == 4 && var5 == 5 && var6 == 6 && var7 == 7 && var8 == 8 && var9 == 9 && var10 == 10 && var11 == 11 && var12 == 12 && var13 == 13 && var14 == 14 && var15 == 15 && var16 == 16 && var17 == 17 && var18 == 18 && var19 == 19 && var20 == 20 && var21 == 21 && var22 == 22 && var23 == 23 && var24 == 24 && var25 == 25 && var26 == 26 && var27 == 27 && var28 == 28 && var29 == 29 && var30 == 30 && var31 == 31  )  ")
    # print(LM.filename)
