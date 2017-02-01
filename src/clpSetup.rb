about = {'name'=>"glitter", 'desc'=>'Template Processing', 'author'=>":kelko:",'mail'=>"kelko@anakrino.de",'licence'=>KELKO::TOOLS::About::LICENSE_CC_BY_NC_SA,'version'=>"1.0"}
KELKO::TOOLS::About.getInstance << about

clp = KELKO::TOOLS::CommandLineParser.getInstance
clp.startMessage = 'Glitter, a template processor, see https://github.com/kelko/glitter'

clp.allowParam('INPUT' , 'The input file to process, - means STDIN', KELKO::TOOLS::CommandLineParser::PARAM_OPTIONAL)
clp.allowParam('OUTPUT' , 'The file the output shall be written into, - means STDOUT', KELKO::TOOLS::CommandLineParser::PARAM_OPTIONAL)

