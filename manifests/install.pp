# the installation part
class scaleio::install inherits scaleio {

    notify { "Installing Components: ${scaleio::components}": } ->
    ####################################
    # Installation of tie-breaker (tb) #
    ####################################
    class { 'scaleio::install::tb': } ->

    ###########################################
    # Installation of meta-data-manager (mdm) #
    ###########################################
    class { 'scaleio::install::mdm': } ->

    ##################################################
    # Installation of Software-Defined-Storage (sds) #
    ##################################################
    class { 'scaleio::install::sds': } ->

    ##################################################
    # Installation of Software-Defined-Client (sdc) #
    ##################################################
    class { 'scaleio::install::sdc': } ->

    #######################
    # Installation of lia #
    #######################
    class { 'scaleio::install::lia': } ->

    ###########################################
    # Installation of Gateway/WebService (gw) #
    ###########################################
    class { 'scaleio::install::gw': } ->

    ##################################################
    # Installation of Graphical User Interface (gui) #
    ##################################################
    class { 'scaleio::install::gui': } ->

    #############################
    # Installation of callhome  #
    #############################
    class { 'scaleio::install::callhome': } ->

    notify { "ScaleIO components installed: ${scaleio::components}": }
}
