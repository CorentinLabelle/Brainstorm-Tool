classdef BackgroundColorSwitcher < handle
    
    properties (Access = private)
        
        BackgroundColor;
        TextColor;
        HyperlinkTextColor;
        
    end
    
    methods (Access = public)
                
        function setBackgroundColor(obj, backgroundColor)
            
            obj.BackgroundColor = backgroundColor;
            
        end
        
        function setTextColor(obj, textColor)
            
            obj.TextColor = textColor;
            
        end
        
        function setHyperlinkTextColor(obj, hyperlinkTextColor)
            
            obj.HyperlinkTextColor = hyperlinkTextColor;
            
        end
        
        function switchBackground(obj, app)
           
            obj.switchParent(app);
            
        end
        
    end
    
    methods (Access = private)       
        
        function switchParent(obj, uiObject)
            
            try 
                children = uiObject.Children;                
                obj.switchObjectColor(uiObject);
        
                for i = 1:length(children)
                    obj.switchParent(children(i));
                end
                
            catch ME
                
                if strcmp(ME.identifier, 'MATLAB:noSuchMethodOrField')
                    obj.switchObjectColor(uiObject);
                else
                    throw(ME);
                end
                
            end
            
        end
        
        function switchObjectColor(obj, uiObject)
           
            cls = class(uiObject);
            
            switch cls

                case 'matlab.ui.control.Button'
                    uiObject.FontColor = obj.TextColor;
                    uiObject.BackgroundColor = obj.BackgroundColor;
                    
                case 'matlab.ui.container.CheckBoxTree'
                    uiObject.BackgroundColor = obj.BackgroundColor;
                    uiObject.FontColor = obj.TextColor;
                    
                case 'matlab.ui.control.DropDown'
                    uiObject.FontColor = obj.TextColor;
                    uiObject.BackgroundColor = obj.BackgroundColor;
                    
                case 'matlab.ui.Figure'
                    uiObject.Color = obj.BackgroundColor; 
                    
                case 'matlab.ui.control.Hyperlink'
                    uiObject.VisitedColor = obj.TextColor;
                    uiObject.BackgroundColor = obj.BackgroundColor;
                    uiObject.FontColor = obj.HyperlinkTextColor; 

                case 'matlab.ui.control.Label'
                    uiObject.BackgroundColor = obj.BackgroundColor;
                    uiObject.FontColor = obj.TextColor;
                    
                case 'matlab.ui.container.Panel'
                    uiObject.BackgroundColor = obj.BackgroundColor;
                    uiObject.ForegroundColor = obj.TextColor;

                case 'matlab.ui.container.Tab'
                    uiObject.BackgroundColor = obj.BackgroundColor;
                    
                case 'matlab.ui.control.TextArea'
                    uiObject.FontColor = obj.TextColor;
                    uiObject.BackgroundColor = obj.BackgroundColor;
             
            end
            
        end
        
    end
    
end

