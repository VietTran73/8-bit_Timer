VLIB = vlib
VMAP = vmap
WORK_LIB = work
VLOG = vlog -work
VSIM = vsim -c 
RUN = -do "run -all"

SRC = $(wildcard src/*)
SRC_V = $(filter %.v, $(SRC))

TB_APB = $(wildcard tb/apb_controller/*)
TB_APB_V = $(filter %.v, $(TB_APB))
NAME_TB = $(notdir $(basename $(TB_APB_V)))

TB_CNT = $(wildcard tb/counter/*)
TB_CNT_V = $(filter %.v, $(TB_CNT))
NAME_TB_CNT = $(notdir $(basename $(TB_CNT_V)))
# notdir láy tên sau cùng cua pwd
# basename is bo duoi .v di

all: init compile sim_apb sim_counter report 

init:
	$(VLIB) $(WORK_LIB)
	$(VMAP) work $(WORK_LIB)
	@mkdir -p output 
compile:
	$(VLOG)	$(WORK_LIB) $(SRC_V)	
	$(VLOG) $(WORK_LIB) $(TB_APB_V)
	$(VLOG) $(WORK_LIB) $(TB_CNT_V)

sim_apb: $(NAME_TB)
	@echo "simulation complete"
$(NAME_TB):
	$(VSIM) $(WORK_LIB).$@ $(RUN)

sim_counter: $(NAME_TB_CNT)
	@echo "simulation complete"
$(NAME_TB_CNT): 
	$(VSIM) $(WORK_LIB).$@ $(RUN)

# $@: lay ten cua target

report:
	@./report.sh
clean:
	@rm -rf output work transcript modelsim.ini report.txt
name_tb:
	@echo "$(TB_APB_V)"
