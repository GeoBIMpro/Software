
catkin_ws := catkin_ws
scuderia := scuderia.yaml
machines := $(catkin_ws)/src/duckietown/machines

all: $(machines)


$(machines): $(scuderia)
	python setup/create-machines-file.py $(scuderia) > $(machines)

fix-time:
	echo "Calling ntpdate to fix time"
	sudo ntpdate -u us.pool.ntp.org 

fix-time2:
	sudo ntpdate -s time.nist.gov

clean-pyc:
	find catkin_ws/src/ -name '*.pyc' | xargs rm 

catkin-clean: clean-pyc
	rm -rf $(catkin_ws)/build

build-parallel:
	catkin_make -C $(catkin_ws) --make-args "-j4"

build:
	catkin_make -C $(catkin_ws) 

# Unit tests
# Teddy: make it so "make unittests" runs all unit tests

unittests-environment:
	bash -c "source environment.sh; python setup/sanity_checks"

unittests:
	$(MAKE) unittests-environment
	bash -c "source environment.sh; catkin_make -C $(catkin_ws) run_tests; catkin_test_results $(catkin_ws)/build/test_results/"


unittests-anti_instagram:
	$(MAKE) unittests-environment
	bash -c "source environment.sh; rosrun anti_instagram annotation_tests.py"

# HW testing 

test-camera:
	echo "Testing Camera HW by taking a picture (smile!)."
	raspistill -t 1000 -o test-camera.jpg


test-led: 
	echo "Calibration blinking pattern"
	bash -c "source environment.sh; rosrun rgb_led blink test_all_1"



# Basic demos

vehicle_name=$(shell hostname)

demo-joystick: unittests-environment
	bash -c "source environment.sh; source set_ros_master.sh;  roslaunch duckietown joystick.launch veh:=$(vehicle_name)"

demo-joystick-camera: unittests-environment
	bash -c "source environment.sh; source set_ros_master.sh;  roslaunch duckietown joystick_camera.launch veh:=$(vehicle_name)"

demo-line_detector: unittests-environment
	bash -c "source environment.sh; source set_ros_master.sh; roslaunch duckietown line_detector.launch veh:=$(vehicle_name)"



demo-joystick-perception: unittests-environment
	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos master.launch fsm_file_name:=joystick"

demo-lane_following-%: unittests-environment
	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos lane_following.launch line_detector_param_file_name:=$* verbose:=false"

demo-led-fancy1: unittests-environment
	bash -c "source environment.sh; rosrun rgb_led fancy1"

demo-led-fancy2: unittests-environment
	bash -c "source environment.sh; rosrun rgb_led fancy2"

demo-led-blink-%: unittests-environment
	bash -c "source environment.sh; rosrun rgb_led blink $*"

demo-line_detector-verbose-default: _demo-line_detector-verbose-default
demo-line_detector-verbose-guy: _demo-line_detector-verbose-guy
demo-line_detector-verbose-universal: _demo-line_detector-verbose-universal
demo-line_detector-verbose-default_ld2: _demo-line_detector-verbose-default_ld2
demo-line_detector-quiet-default: _demo-line_detector-quiet-default
demo-line_detector-quiet-guy: _demo-line_detector-quiet-guy
demo-line_detector-quiet-universal: _demo-line_detector-quiet-universal
demo-line_detector-quiet-default_ld2: _demo-line_detector-quiet-default_ld2

_demo-line_detector-verbose-%: unittests-environment
	bash -c "source environment.sh; source set_ros_master.sh; roslaunch duckietown line_detector.launch veh:=$(vehicle_name) line_detector_param_file_name:=$* verbose:=true"

_demo-line_detector-quiet-%: unittests-environment
	bash -c "source environment.sh; source set_ros_master.sh; roslaunch duckietown line_detector.launch veh:=$(vehicle_name) line_detector_param_file_name:=$* verbose:=false"

# ==========
# openhouse demos
 

# openhouse-dp3-%-verbose: unittests-environment
# 	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos indefinite_navigation.launch  line_detector_param_file_name:=$* verbose:=true"

# openhouse-dp3-%-notverbose: unittests-environment
# 	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos indefinite_navigation.launch  line_detector_param_file_name:=$* verbose:=false"
# =========

openhouse-dp3: unittests-environment
	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos indefinite_navigation.launch"

# openhouse-dp3-ld1a: unittests-environment
# 	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos indefinite_navigation.launch  line_detector_param_file_name:=default"

# openhouse-dp3-1d1b: unittests-environment
# 	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos indefinite_navigation.launch  line_detector_param_file_name:=Guy anti_instagram:=true"

# openhouse-dp3-1d1c: unittests-environment
# 	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos indefinite_navigation.launch  line_detector_param_file_name:=universal anti_instagram:=true"

# openhouse-dp3-1d2a: unittests-environment
# 	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos indefinite_navigation.launch  line_detector_param_file_name:=default anti_instagram:=true /lane_following/line_detection:=false /lane_following/line_detection2:=true"

# openhouse-dp3-1d2b: unittests-environment
# 	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos indefinite_navigation.launch  line_detector_param_file_name:=universal anti_instagram:=true /lane_following/line_detection:=false /lane_following/line_detection2:=true"



openhouse-dp2: unittests-environment
	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos obstacle_vehicle_avoid.launch"

openhouse-dp2-vehicle: unittests-environment
	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos vehicle_avoid.launch"

openhouse-dp2-obstacle: unittests-environment
	bash -c "source environment.sh; source set_ros_master.sh; source set_vehicle_name.sh; roslaunch duckietown_demos obstacle_avoid.launch"
