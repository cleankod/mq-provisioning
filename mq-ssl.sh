#!/bin/bash
#####################################################
# This script generates all necesary SSL certificates
# for both the server and the client.
#####################################################

############ [ INIT ] ############
MQBIN=/opt/mqm/bin
MQCERTCOMMAND=${MQBIN}/runmqckm
MQSSLDN='CN=John Smith, OU=Tivoli, O=IBM, C=US'
MQHOME=/var/mqm
QMGRNAME=$1
MQSSLDIR=${MQHOME}/qmgrs/${QMGRNAME}/ssl
MQKEYRINGDIR=${MQHOME}/ssl
MQSSLEXPIREDAYS=365
password=$2


############ [ CLEAR DIRS ] ############
rm -rf ${MQSSLDIR}/*
rm -rf ${MQKEYRINGDIR}
mkdir ${MQKEYRINGDIR}


############ [ GENERATE SERVER SSL ] ############

# Convert Qmgr name to lowercase:
QMGRNAME_LOWERCASE=`echo ${QMGRNAME} | awk '{print tolower($0)}'`

# Create ${QMGRNAME} key repository :
${MQCERTCOMMAND}  -keydb -create -db ${MQSSLDIR}/${QMGRNAME_LOWERCASE}.kdb -pw ${password} -type cms -expire ${MQSSLEXPIREDAYS} -stash

# Create CA repository :
${MQCERTCOMMAND}  -keydb -create -db ${MQKEYRINGDIR}/wmqca.kdb -pw ${password} -type cms -expire ${MQSSLEXPIREDAYS} -stash

# Create CA certificate:
${MQCERTCOMMAND}  -cert -create -db ${MQKEYRINGDIR}/wmqca.kdb -pw ${password} -label wmqca -dn "${MQSSLDN}" -expire ${MQSSLEXPIREDAYS}

# Extract the public CA certificate
${MQCERTCOMMAND} -cert -extract -db ${MQKEYRINGDIR}/wmqca.kdb -pw ${password} -label wmqca -target ${MQKEYRINGDIR}/wmqca.crt -format ascii

# Add the public CA certificate to ${QMGRNAME}'s key repository:
${MQCERTCOMMAND} -cert -add -db ${MQSSLDIR}/${QMGRNAME_LOWERCASE}.kdb -pw ${password} -label wmqca -file ${MQKEYRINGDIR}/wmqca.crt -format ascii

# Create ${QMGRNAME}'s certificate request :
${MQCERTCOMMAND} -certreq -create -db ${MQSSLDIR}/${QMGRNAME_LOWERCASE}.kdb -pw ${password} -label ibmwebspheremq${QMGRNAME_LOWERCASE} -dn "${MQSSLDN}" -file ${MQKEYRINGDIR}/${QMGRNAME_LOWERCASE}req.arm

# Sign ${QMGRNAME}'s certificate:
${MQCERTCOMMAND} -cert -sign -file ${MQKEYRINGDIR}/${QMGRNAME_LOWERCASE}req.arm -db ${MQKEYRINGDIR}/wmqca.kdb -pw ${password} -label wmqca -target ${MQKEYRINGDIR}/${QMGRNAME_LOWERCASE}cert.arm -format ascii -expire 29

# Add ${QMGRNAME}'s certificate to ${QMGRNAME}'s key repository:
${MQCERTCOMMAND} -cert -receive -db ${MQSSLDIR}/${QMGRNAME_LOWERCASE}.kdb -pw ${password} -file ${MQKEYRINGDIR}/${QMGRNAME_LOWERCASE}cert.arm -format ascii

# Set ${QMGRNAME}'s queue manager key repository :
sudo -u mqm -H sh -c "${MQBIN}/runmqsc ${QMGRNAME}" <<< "ALTER QMGR SSLKEYR('${MQHOME}/qmgrs/${QMGRNAME}/ssl/')"

# All channels that are to be encrupted, need the following alteration:
# ALTER CHANNEL(ADM.CHANNEL) CHLTYPE(SVRCONN) SSLCIPH(TRIPLE_DES_SHA_US)


############ [ GENERATE CLIENT SSL ] ############

# Create a key Database file
${MQCERTCOMMAND} -keydb -create -db ${MQKEYRINGDIR}/${QMGRNAME_LOWERCASE}.jks -pw ${password} -type jks

# Add CA cert to database:
${MQCERTCOMMAND} -cert -add -db ${MQKEYRINGDIR}/${QMGRNAME_LOWERCASE}.jks -pw ${password} -label wmqca -file ${MQKEYRINGDIR}/wmqca.crt -format ascii

# Create a certificate request:
${MQCERTCOMMAND} -certreq -create -db ${MQKEYRINGDIR}/${QMGRNAME_LOWERCASE}.jks -pw ${password} -label explorer -dn "${MQSSLDN}" -file ${MQKEYRINGDIR}/expreq1.arm

# Sign the cert:
${MQCERTCOMMAND} -cert -sign -file ${MQKEYRINGDIR}/expreq1.arm -db ${MQKEYRINGDIR}/wmqca.kdb -pw ${password} -label wmqca -target ${MQKEYRINGDIR}/expreq1.arm -format ascii -expire ${MQSSLEXPIREDAYS}

# Receive the cert:
${MQCERTCOMMAND} -cert -receive -db ${MQKEYRINGDIR}/${QMGRNAME_LOWERCASE}.jks -pw ${password} -file ${MQKEYRINGDIR}/expreq1.arm -format ascii

# Copy generated client certs to vagrant directory:
cp ${MQKEYRINGDIR}/${QMGRNAME_LOWERCASE}.jks /install/certs