({
    getPass: function(cmp, evt, passType) {
        var helper = this;
        helper.init(cmp,evt);
        if(cmp.get('v.sendPassByEmail')&&cmp.get('v.passEmailID')==''){
            helper.showToast(cmp,evt,'Error','Email ID is required');
            return;
        }
        helper.showSpinner(cmp,evt);
        var apexMethod = cmp.get('c.getSamplePass');
        apexMethod.setParams({
            passType: cmp.get('v.passType'),
            processAtClient: cmp.get('v.processAtClient'),
            sendPassByEmail: cmp.get('v.sendPassByEmail'),
            emalID: cmp.get('v.passEmailID')
        });
        helper.printLog(cmp, evt,'Gate1: Calling Apex')
        apexMethod.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var ret = JSON.parse(response.getReturnValue());
                if (cmp.get('v.processAtClient')) {
                    ret.passJSON = JSON.parse(ret.passJSON);
                    cmp.set('v.returnPass', ret);
                    helper.printLog(cmp, evt,'Gate2: Creating Manifest');
                    helper.getManifest(cmp, evt);
                } else {
                    helper.printLog(cmp,evt,'Gate2: Downloading Pass');
                    ret.passFile = 'data:application/vnd.apple.pkpass;base64,' + ret.passFile;
                    cmp.set('v.returnPass', ret);
                    helper.downloadPass(cmp, evt);
                }
            } else {
                console.log("Error in calling Apex method: ", response);
            }
        });
        $A.enqueueAction(apexMethod);
    },

    checkValidFile: function(cmp, evt, entry) {
        if (!entry.directory && !entry.filename.startsWith('__MACOSX') && !entry.filename.startsWith('.DS_Store')) {
            return true;
        } else {
            return false;
        }
    },


    getManifest: function(cmp, evt) {
        //Place Holder for future when Blob is supported in Locker Service
        cmp.set('v.manifest', {});
        cmp.set('v.resourceFiles', new Array());
        var helper = this;
        var ret = cmp.get('v.returnPass');
        var dataURI = 'data:application/zip;base64,' + ret.passFile;
        zip.createReader(new zip.Data64URIReader(dataURI), function(reader) {
            reader.getEntries(function(entries) {
                if (entries.length) {
                    cmp.set('v.fileCounter', entries.length);
                    entries.forEach(function(entry, index) {
                        entry.getData(new zip.Data64URIWriter(), function(fileText) {
                            var filename = entry.filename;
                            var fileCounter = cmp.get('v.fileCounter');
                            fileCounter = fileCounter - 1;
                            cmp.set('v.fileCounter', fileCounter);
                            if (helper.checkValidFile(cmp, evt, entry)) {
                                var manifest = cmp.get('v.manifest');
                                var base64Data = fileText.split(',')[1];
                                manifest[filename] = helper.getSHA1(cmp, evt, base64Data, 'B64');
                                cmp.set('v.manifest', manifest);
                                var resourceFiles = cmp.get('v.resourceFiles');
                                var resourceFile = {};
                                resourceFile.name = filename;
                                resourceFile.data = fileText;
                                resourceFiles.push(resourceFile);
                                cmp.set('v.resourceFiles', resourceFiles);
                            }
                            if (fileCounter <= 0) {
                               helper.printLog(cmp, evt,'Gate3: Getting Signature');
                                helper.getSignature(cmp, evt);
                            }

                        });
                    });
                }
            })

        })

    },

    getDigest: function(cmp, evt, entry) {
        var helper = this;
        entry.getData(new zip.Data64URIWriter(), function(fileText) {
            var filename = entry.filename;
            var fileCounter = cmp.get('v.fileCounter');
            fileCounter = fileCounter - 1;
            cmp.set('v.fileCounter', fileCounter);
            if (helper.checkValidFile(cmp, evt, entry)) {
                var manifest = cmp.get('v.manifest');
                //May need to change this for blob
                var base64Data = fileText.split(',')[1];
                manifest[filename] = helper.getSHA1(cmp, evt, base64Data, 'B64');
                cmp.set('v.manifest', manifest);
                var resourceFiles = cmp.get('v.resourceFiles');
                var resourceFile = {};
                resourceFile.name = filename;
                resourceFile.data = fileText;
                resourceFiles.push(resourceFile);
                cmp.set('v.resourceFiles', resourceFiles);
            }
            if (fileCounter <= 0) {
                helper.getSignature(cmp, evt);
            }

        });
    },

    getSHA1: function(cmp, evt, fileText, format) {
        var shaObj = new jsSHA("SHA-1", format);
        shaObj.update(fileText);
        return shaObj.getHash("HEX");
    },


    getSignature: function(cmp, evt) {

        //Add Pass.json to manifest
        var manifest = cmp.get('v.manifest');
        var helper = this;
        var ret = cmp.get('v.returnPass');
        manifest['pass.json'] = helper.getSHA1(cmp, evt, ret.passJSON, "TEXT");
        cmp.set('v.manifest', manifest);

        manifest = JSON.stringify(manifest);
        cmp.set('v.manifest', manifest);

        var signature;
        var apexMethod = cmp.get('c.getSignature');
        apexMethod.setParams({
            passType: cmp.get('v.passType'),
            manifestJSON: manifest
        });

       helper.printLog(cmp, evt,'Gate4: Calling Apex for Signature');
       
        apexMethod.setCallback(this, function(response) {
            helper.printLog(cmp, evt,'Gate5: Got Signature from Apex');
            var state = response.getState();
            if (state == 'SUCCESS') {
                var signature = response.getReturnValue();
                helper.getPassBundle(cmp, evt, signature);
            } else {
                console.log("Error in calling Apex method: ", response);
            }
        });
        $A.enqueueAction(apexMethod);


    },

    getPassBundle: function(cmp, evt, signature) {
        var ret = cmp.get('v.returnPass');
        var resourceFiles = cmp.get('v.resourceFiles');
        var manifest = cmp.get('v.manifest');
        var helper = this;

        var file = {};
        file.name = 'manifest.json';
        file.data = 'data:application/zip;base64,' + window.btoa(manifest);
        resourceFiles.push(file);

        file = {};
        file.name = 'signature';
        file.data = 'data:application/zip;base64,' + signature;
        resourceFiles.push(file);

        file = {};
        file.name = 'pass.json';
        file.data = 'data:application/zip;base64,' + window.btoa(ret.passJSON);
        resourceFiles.push(file);

        var model = helper.writer(cmp, evt);
        model.setCreationMethod("URI");

        model.addFiles(resourceFiles,
            function() {
                // Initialise Method
                //console.log("Initialise");
            },
            function(file) {
                // OnAdd
                //console.log("Added file");
            },
            function(current, total) {
                // OnProgress
                //console.log("%s %s", current, total);
            },
            function() {
                // OnEnd
                // The zip is ready prepare download link
                // <a id="downloadLink" href="blob:url">Download Zip</a>
                model.getBlob(function(blob) {
                    ret.passFile = blob;
                    cmp.set('v.returnPass', ret);
                   helper.printLog(cmp, evt,'Gate6: Created Pass Zip');
                    helper.downloadPass(cmp, evt);
                });
            });


    },


    writer: function(cmp, evt) {
        var zipFileEntry, zipWriter, writer, creationMethod, URL = '';

        return {
            setCreationMethod: function(method) {
                creationMethod = method;
            },
            addFiles: function addFiles(files, oninit, onadd, onprogress, onend) {
                var addIndex = 0;

                function nextFile() {
                    var file = files[addIndex];
                    onadd(file);
                    // Modified here to use the Data64URIReader instead of BlobReader
                    zipWriter.add(file.name, new zip.Data64URIReader(file.data), function() {
                        addIndex++;
                        if (addIndex < files.length)
                            nextFile();
                        else
                            onend();
                    }, onprogress);
                }

                function createZipWriter() {
                    zip.createWriter(writer, function(writer) {
                        zipWriter = writer;
                        oninit();
                        nextFile();
                    }, onerror);
                }

                if (zipWriter)
                    nextFile();
                else if (creationMethod == "URI") {
                    writer = new zip.Data64URIWriter('application/vnd.apple.pkpass');
                    createZipWriter();
                } else {
                    createTempFile(function(fileEntry) {
                        zipFileEntry = fileEntry;
                        writer = new zip.FileWriter(zipFileEntry);
                        createZipWriter();
                    });
                }
            },
            getBlobURL: function(callback) {
                zipWriter.close(function(blob) {
                    var blobURL = creationMethod == "Blob" ? URL.createObjectURL(blob) : zipFileEntry.toURL();
                    callback(blobURL);
                    zipWriter = null;
                });
            },
            getBlob: function(callback) {
                zipWriter.close(callback);
            }
        };
    },



    downloadPass: function(cmp, evt) {
        var helper = this;
        var ret = cmp.get('v.returnPass');
        if (cmp.get('v.sendPassByEmail')) {
            if(cmp.get('v.processAtClient')){
                helper.sendPassByEmail(cmp,evt);    
            }else{
                helper.hideSpinner(cmp,evt);
                if(ret.success){
                    helper.showToast(cmp,evt,'Success','Pass successfully sent by email');
                }else{
                     helper.showToast(cmp,evt,'Error',ret.message);
                }
                
            }
        } else {
            var ret = cmp.get('v.returnPass');
            helper.hideSpinner(cmp,evt);
            var passFrame = cmp.find('_passFrame');
            passFrame.getElement().contentWindow.postMessage(ret.passFile, '*');
            
        }

    },

    sendPassByEmail: function(cmp,evt){
        var helper = this;
        var ret = cmp.get('v.returnPass');
        ret.passFile = ret.passFile.replace('data:application/vnd.apple.pkpass;base64,','');
        var apexMethod = cmp.get('c.sendPassByEmail');
        apexMethod.setParams({
            emailID: cmp.get('v.passEmailID'),
            passFile: ret.passFile
        });

        apexMethod.setCallback(this, function(response) {
            helper.printLog(cmp, evt,'Gate7: Sent email through Apex');
            helper.hideSpinner(cmp,evt);
            var state = response.getState();
            if (state == 'SUCCESS') {
                var ret = JSON.parse(response.getReturnValue());
                if(ret.success){
                    helper.showToast(cmp,evt,'Success','Pass successfully sent by email');
                }else{
                    helper.showToast(cmp,evt,'Error',ret.message);
                }
                
            } else {
                helper.showToast(cmp,evt,'Error','Error in calling Apex method');
            }
        });

        $A.enqueueAction(apexMethod);
    },

    printLog: function(cmp,evt,message){
        console.log(new Date() + '' + message);
    },

    showToast: function(cmp,evt,title,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },

    showSpinner: function(cmp,evt){
        $A.util.removeClass(cmp.find('_spinner'), "slds-hide")
    },

    hideSpinner: function(cmp,evt){
        $A.util.addClass(cmp.find('_spinner'), "slds-hide")
    },   

    init:function(cmp,evt){
        cmp.set('v.returnPass','');
        cmp.set('v.manifest',{});
        cmp.set('v.fileCounter',0);
        cmp.set('v.resourceFiles',{});
    }

})
