//set the number of states
N:nStates:2;
//set the tolerance of change in likelihood
tol:10 xexp -7;
//set the maximum number of iterations
maxIter:500;
//set initial log likelihood for first two iterations
iniLL:(-3; -2);

forwardBackward:{[data;arg]
    //The primary function which performs the actual Baum-Welch algorithm
    //data -- one dimensional array of log returns
    //arg -- dictionary of parameters:
        //arg`mu -- array of means for each state
        //arg`sigma -- array of standard deviations for each state
        //arg`logLikelihood -- array of the log likelihood history
        //arg`Tau -- transition matrix
        //arg`delta -- array of initial state probability
        //arg`gamma -- array of periodic state probability
        //arg`counter -- number of iterations 

    
    //define number of time steps
    T:count data;
   
    //2-dim array of normal densities
    B:flip getNormalDensity[data;arg;] each til N;
   //todo:change B to density
   

    //carry out forward recursion method-----------------------------------
    Alpha: (T;N)#0f;
    Alpha[0]:(arg`delta) * B[0];
    //nu:scaling factor which normalizes alpha
    Nu: T#0f;
    Nu[0]:reciprocal sum@Alpha[0];
    Alpha[0] *: Nu[0];
    
    t:1;
    while[t<T;
         Alpha[t]: B[t] * Alpha[t-1] mmu (arg`Tau) ;
         Nu[t]:reciprocal sum@Alpha[t];
         Alpha[t] *: Nu[t];
         t+:1];
         

   //update complete data log likelihood
   logLikelihoodNew: (arg`logLikelihood),enlist[neg sum@log[Nu]];
  
   //carry out backward recursion method
   Beta:(T; N)#0f;
   Beta[T-1]:N#Nu[T-1];    
 
   t:T-2;
   while[t>=0;
        Beta[t]:Nu[t] * (arg`Tau) mmu Beta[t+1] *  B[t+1];
        t-:1];
    
    

    //carry out E-step-----------
    //gamma-----------
    Gamma: getWeights each Alpha*Beta;
     
    
    //--------Xi----------------
    //note that we don't need the individual Xi_t
    
    Xi:(2 2)#0f;
    t:0;
    
    while[t<=T-2;
        Xi+:normalizeMatrix[(arg`Tau) * Alpha[t] *\: Beta[t+1]*B[t+1]];
        t+:1];
    

    //carry out M-step----------------------------------------
    //update Tau: transition matrix
    TauNew: getWeights each Xi;
    //update delta: initial distribution
    deltaNew: first@Gamma;
    //get observation weights
    weights: getWeights each flip Gamma;
   
    //update mu
    muNew:weights mmu data;
    //update sigma
    sigmaNew:sqrt@sum each weights*{[data;x](data - x)}[data]'[muNew] xexp 2;
    //counter increment
    counterNew:1+arg`counter;
    
   :`delta`Tau`mu`sigma`logLikelihood`counter`gamma!(deltaNew; TauNew; muNew; sigmaNew; logLikelihoodNew; counterNew; Gamma);
   };


xInitialTest:{[data]
    //A set of 20 initial guesses are run for five iterations, the one with the highest likelihood is selected
    iniGuess:xRandomInit[data;]'[20#nStates],'tbl:([]logLikelihood:20#enlist (-3;-2);counter:20#0);
    
    iniResults: constraint[tol;5;] (forwardBackward[data;]/)' iniGuess;
    
    //CDLL: complate data log likelihood, last item of log likelihood history 
    CDLL: last each iniResults`logLikelihood;
    
    //search the row with lowest CDLL
    tbl0:flip enlist[`CDLL]!enlist CDLL;
    tbl1:iniResults,' tbl0;
    tbl2:`CDLL xasc tbl1;
    d1:`delta`Tau`mu`sigma!last[tbl2][`delta`Tau`mu`sigma];
    d2:`logLikelihood`counter!((-3;-2);0);
    :d1,d2;
    };

//Compute the equilibrium distribution for a Markov Chain
xMarkovChainEquilibrium:{[transiMatrix] 
    n:count transiMatrix;
    I:9h${x=/:x}@til n;
    one:n#1f;
    U:(n;n)#1f;
    :neg one mmu inv[I - transiMatrix + U];
  };
 
//Generate a random parameter to initialize the Baum-Welch algorithm for HMM models
xRandomInit:{[data; nStates]
    //generate a random transition matrix A
    A:getWeights each (nStates; nStates)#(nStates*nStates)?1f;
    
    //compute equilibrium distribution v from A
    v:xMarkovChainEquilibrium[A];
    
    //generate mean m and standard deviation for each state
    m:(avg data)* getWeights@-1+nStates?2f;
    s:sqrt@(var data)* getWeights@nStates?2f;
    :`delta`Tau`mu`sigma!(v;A;m;s);
    };


constraint:{[constr; cnt; argument] 
    //define constraint to control termination
    //constr: tolerance of change in likelihood
    //cnt:maximum number of iterations
    (diffLogLikelihood[argument[`logLikelihood]] > constr) and (argument[`counter]<cnt)
    };

//compute relative difference of log likelihood between last two iterations: LL_T/LL_{T-1} -1
diffLogLikelihood:{[x] abs 1-last@x%last@-1_x}; 

normalstdCDF:{[x] 0.5*1+.qml.erf[x%sqrt 2]};

normalPDF:{[mu; sigma; x] (1% sigma*sqrt 2*(.qml.pi)) *exp neg ((x-mu) xexp 2)%2*sigma xexp 2};

getNormalDensity:{[data;arg;state] normalPDF[(arg`mu)[state]; (arg`sigma)[state]; data]};

getWeights:{[list] list % sum@list };

normalizeMatrix:{[m] m%sum@raze[m] };






