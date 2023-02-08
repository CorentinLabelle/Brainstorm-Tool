classdef TreeManager < handle
    
    properties (Access = private)
        
        Tree
        
    end
    
    methods (Access = ?App_Manager)
        
        function obj = TreeManager(tree)
            
            obj.Tree = tree;
            
        end
        
        function updateTree(obj)
        % Update Informations in Tree

            obj.clear();
            
            studies = bst_get('ProtocolStudies');

            for i = 1:length(studies.Study)
                obj.addStudy(studies.Study(i));
            end
            
            obj.expand();

        end
        
        function updateTreeAndCheckNewStudies(obj)
           
            oldSubjectAndStudy = obj.saveSubjectAndStudyAsString();
            obj.updateTree();
            newStudyNodes = obj.getAllStudyNodes();
            
            repeatedNodes = obj.getRepeatedNodes(oldSubjectAndStudy, newStudyNodes);
               
            nodesToCheck = setdiff(newStudyNodes, repeatedNodes);
            if isempty(nodesToCheck)
                obj.Tree.CheckedNodes = [];
            else
                obj.Tree.CheckedNodes = nodesToCheck;
            end
            
        end
        
        function sFiles = selectedStudies(obj)
            
            studyNodesChecked = obj.Tree.CheckedNodes;
            
            sFiles = [];
            for i = 1:length(studyNodesChecked)
                
                if obj.isSubjectNode(studyNodesChecked(i))
                    continue;
                end
                
                if any(contains(studyNodesChecked(i).Text, ["intra" "default"]))
                    continue;
                end
                
                sFile = obj.selectsFileWithNode(studyNodesChecked(i));                
                sFiles = [sFiles sFile];
                
            end
            
        end
        
        function selectOrDeselectAllStudies(obj)
            
            if isempty(obj.Tree.CheckedNodes)
                obj.Tree.CheckedNodes = obj.Tree.Children;
            else
                obj.Tree.CheckedNodes = [];
            end
            
        end
        
        function expand(obj)
            
            expand(obj.Tree, "all");
            
        end
        
        function clear(obj)
            
            obj.Tree.Children.delete;
            
        end
        
        function selectRawStudies(obj)
           
            studyNodes = obj.getAllStudyNodes();
            
            nodesToCheck = [];
            for i = 1:length(studyNodes)
                if obj.isStudyRaw(studyNodes(i))
                    nodesToCheck = [nodesToCheck studyNodes(i)];
                end               
            end
            
            obj.Tree.CheckedNodes = nodesToCheck;
            
        end
        
        function selectImportedStudies(obj)
            
           studyNodes = obj.getAllStudyNodes();
            
            nodesToCheck = [];
            for i = 1:length(studyNodes)
                if obj.isStudyImported(studyNodes(i))
                    nodesToCheck = [nodesToCheck studyNodes(i)];
                end               
            end
            
            obj.Tree.CheckedNodes = nodesToCheck;
            
        end
        
    end
    
    methods (Access = private)
       
        function subjectAndStudyAsString = saveSubjectAndStudyAsString(obj)
           
            studyNodes = obj.getAllStudyNodes();
            
            subjectAndStudyAsString = cell(1, length(studyNodes));
            
            for i = 1:length(studyNodes)
                subjectAndStudyAsString{i} = ...
                    string(...
                    {obj.getSubjectFromStudyNode(studyNodes(i)), ...
                    obj.getStudyFromStudyNode(studyNodes(i))}...
                    );
            end
            
        end
        
        function addStudy(obj, study)
            
            subjectNameChar = strsplit(study.BrainStormSubject, '/');
            subjectNameString = string(subjectNameChar{1});

            if any(obj.isSubjectInTree(subjectNameString))
                subjectNode = obj.getSubjectNodeWithName(subjectNameString);
            else
                subjectNode = obj.createParentNode(subjectNameString);
            end

            obj.createChildNode(subjectNode, study.Name);
            
        end
        
        function node = createParentNode(obj, nodeText)
            
            node = obj.createChildNode(obj.Tree, nodeText);
            
        end
        
        function node = createChildNode(~, parentNode, nodeText)
            
            node = uitreenode(parentNode);
            node.Text = nodeText;
            
        end  
        
        function studyNodes = getAllStudyNodes(obj)
            
            studyNodes = matlab.ui.container.TreeNode.empty();
            
            for i = 1:length(obj.Tree.Children)
                for j = 1:length(obj.Tree.Children(i).Children)
                    studyNodes(end+1) = obj.Tree.Children(i).Children(j);
                end
            end
            
        end
        
        function repeatedNodes = getRepeatedNodes(obj, oldSubjectAndStudy, newStudyNodes)
            
            repeatedNodes = matlab.ui.container.TreeNode.empty();
            
            for i = 1:length(newStudyNodes)
                currentSubject = obj.getSubjectFromStudyNode(newStudyNodes(i));
                currentStudy = obj.getStudyFromStudyNode(newStudyNodes(i));
                
                if any(cellfun(@(x) ...
                        isequal(x(1), currentSubject) && ...
                        isequal(x(2), currentStudy)...
                            , oldSubjectAndStudy))
                        
                    repeatedNodes(end+1) = newStudyNodes(i);
                end
                
            end 
            
        end
        
        function subjectNodes = getSubjectNodes(obj)
        
            subjectNodes = obj.Tree.Children;
            
        end
        
        function subjectNames = getSubjectNames(obj)
           
            subjectNodes = obj.getSubjectNodes();
            if isempty(subjectNodes)
                subjectNames = string.empty();
            else
                subjectNames = string({subjectNodes.Text});
            end
            
        end
        
        function studyNames = getStudyNames(obj)
           
            studyNodes = obj.getAllStudyNodes();
            if isempty(studyNodes)
                studyNames = string.empty();
            else
                studyNames = string({studyNodes.Text});
            end
            
        end
        
        function isIn = isSubjectInTree(obj, subjectNameToFind)
        
            subjectNames = obj.getSubjectNames();
            
            if isempty(subjectNames)
                isIn = false;
            else
                isIn = contains(subjectNames, subjectNameToFind);
            end
            
        end
        
        function subjectNode = getSubjectNodeWithName(obj, subjectNameToFind)
            
            index = contains(obj.getSubjectNames(), subjectNameToFind);
            subjectNodes = obj.getSubjectNodes();
            subjectNode = subjectNodes(index);
            
        end

    end
    
    methods (Static)
       
        function subjectName = getSubjectFromStudyNode(studyNode)
            
            parent = [studyNode.Parent];
            subjectName = string({parent.Text});
            
        end
        
        function studyName = getStudyFromStudyNode(studyNode)
            
            studyName = string({studyNode.Text});
            
        end
        
        function isSubject = isSubjectNode(node)
        
            parentNode = node.Parent;
            isSubject = strcmpi(class(parentNode), "matlab.ui.container.CheckBoxTree");
            
        end
        
        function sFile = selectsFileWithNode(node)
           
            subjectName = node.Parent.Text;
            condition = node.Text;
            sFile = DatabaseSearcher.selectFiles(subjectName, condition);
            
        end
        
        function isEqual = areStudyNodesEqual(studyNode1, studyNode2)
           
            isEqual = true;
            
            if ~strcmpi(studyNode1.Text, studyNode2.Text)
                isEqual = false;
                return
            end
            
            if ~strcmpi(studyNode1.Parent.Text, studyNode2.Parent.Text)
                isEqual = false;
                return
            end
            
        end
        
        function isRaw = isStudyRaw(study)
            
            isRaw = contains(study.Text, '@');
            
        end
        
        function isImported = isStudyImported(study)
           
            isImported = ~contains(study.Text, '@');
            
        end
                
    end
    
end

