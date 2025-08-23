from fastapi import FastAPI, Request
from pydantic import BaseModel
from LogExAn.LogicalAnalyser import LogAn

app = FastAPI()

class ExpressionBody(BaseModel):
    expression: str

@app.post("/{solution}/{output}")
async def solutions(solution: str, output: str, body: ExpressionBody):

    condition = body.expression
    try:
        LA = LogAn(condition)
        result = None
        if(solution == "abstract"):
            if(output == "DICT"):
                result = LA.solution(output)
            elif(output == "JSON"):
                result = LA.solution(output)
            else:
                result = "abstract solution returns output format only in DICT or JSON"
        elif(solution == "elaborate"):
            if(output == "DATAFRAME"):
                result = LA.elaborate_solution(output)
            elif(output == "MARKDOWN"):
                result = LA.elaborate_solution(output)
            else:
                result = "elaborate solution returns output format only in DATAFRAME or MARKDOWN"
        else:
            result = "solution can only be abstract or elaborate"
    except:
        result = "condition not correct"

    return {"solution": solution, "format": output, "result": result}

if __name__ == '__main__':

    import uvicorn
    uvicorn.run(
        app="backend:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )