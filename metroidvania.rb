require './model/model.rb'
require './view/view.rb'
require './controller/controller.rb'
require './manager.rb'



M = Model::Model.new
V = View::View.new [640,480], [255,255,255]
C = Controller::Controller.new
Manager.run M, V, C
