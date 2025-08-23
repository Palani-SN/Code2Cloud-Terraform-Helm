from flask import Flask, request, render_template
from LogicMap import Logic_Map


app = Flask(__name__)
app._static_folder = 'static'


@app.route('/')
def my_form():
    # filename = 'my-form.html'
    filename = 'index.html'
    return render_template(filename)


@app.route('/', methods=['POST'])
def my_form_post():
    condition = request.form['Expression']
    cond = Logic_Map(condition)
    with open("templates/output.html", "r") as InpFile:
        init_html = InpFile.read()
    cond_html = init_html.replace("#COND_STR#", condition)
    final_html = cond_html.replace("#IMAGE_URL#", cond.filename)
    return final_html


# main driver function
if __name__ == '__main__':

    import os

    filelist = [f for f in os.listdir("static/img/") if f != "About.JPG"]
    for f in filelist:
        os.remove(os.path.join("static/img/", f))

    # run() method of Flask class runs the application
    # on the local development server.
    app.run(host="0.0.0.0", port=5000, debug=True)
