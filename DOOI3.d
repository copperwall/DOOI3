import std.stdio;

// Empty interface for ExprC expressions.
interface ExprC {}

// ExprC class defintions
class NumC : ExprC {
   int n;

   this(int n) {
      this.n = n;
   }
}

class LamC : ExprC {   
    string params;
    ExprC bod;

    this(string params, ExprC bod) {
	this.params = params;
	this.bod = bod;
    }
}

class If : ExprC {
    ExprC left;
    ExprC middle;
    ExprC right;

    this(ExprC left, ExprC middle, ExprC right) {
	this.left = left;
	this.middle = middle;
	this.right = right;
    }
}


class Binop : ExprC {
    string name;
    ExprC left;
    ExprC right;

    this(string name, ExprC left, ExprC right) {
	this.name = name;
	this. left = left;
	this.right = right;
    }
}


class IdC : ExprC {
   string s;

   this(string s) {
      this.s = s;
   }
}



class AppC : ExprC {
   ExprC fun;
   ExprC[] args;

   this(ExprC fun, ExprC[] args) {
      this.fun = fun;
      this.args = args;
   }
}

void main()
{

}
