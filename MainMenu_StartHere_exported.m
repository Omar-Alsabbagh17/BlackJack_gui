classdef MainMenu_StartHere_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        intro_image         matlab.ui.control.Image
        MULTIPLAYERButton   matlab.ui.control.Button
        SINGLEPLAYERButton  matlab.ui.control.Button
        Image               matlab.ui.control.Image
    end

    
    properties (Access = private)
        Fs; % Description
        ya;
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            [audio, fs] = audioread('INTRO_soundeffect.wav');
            sound (audio, fs); 
            pause(4);
            clear sound;
            app.intro_image.Visible = 'off';
            [audio, fs] = audioread('MainMenu_soundeffect.mp3');
             sound (audio, fs);

        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            clear sound;
            delete(app)
            
        end

        % Button pushed function: SINGLEPLAYERButton
        function SINGLEPLAYERButtonPushed(app, event)
            SinglePlayer;
            close(app.UIFigure)
        end

        % Button pushed function: MULTIPLAYERButton
        function MULTIPLAYERButtonPushed(app, event)
            MultiPlayer;
            close(app.UIFigure)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.ScaleMethod = 'fill';
            app.Image.Position = [1 1 640 480];
            app.Image.ImageSource = 'poker_table.jpg';

            % Create SINGLEPLAYERButton
            app.SINGLEPLAYERButton = uibutton(app.UIFigure, 'push');
            app.SINGLEPLAYERButton.ButtonPushedFcn = createCallbackFcn(app, @SINGLEPLAYERButtonPushed, true);
            app.SINGLEPLAYERButton.BackgroundColor = [0.1333 0.1333 0.6706];
            app.SINGLEPLAYERButton.FontSize = 18;
            app.SINGLEPLAYERButton.FontColor = [1 1 1];
            app.SINGLEPLAYERButton.Position = [186 292 250 62];
            app.SINGLEPLAYERButton.Text = 'SINGLE PLAYER';

            % Create MULTIPLAYERButton
            app.MULTIPLAYERButton = uibutton(app.UIFigure, 'push');
            app.MULTIPLAYERButton.ButtonPushedFcn = createCallbackFcn(app, @MULTIPLAYERButtonPushed, true);
            app.MULTIPLAYERButton.BackgroundColor = [0.7804 0.0314 0.0314];
            app.MULTIPLAYERButton.FontSize = 18;
            app.MULTIPLAYERButton.FontColor = [1 1 1];
            app.MULTIPLAYERButton.Position = [186 200 250 62];
            app.MULTIPLAYERButton.Text = 'MULTI PLAYER';

            % Create intro_image
            app.intro_image = uiimage(app.UIFigure);
            app.intro_image.Position = [1 15 639 501];
            app.intro_image.ImageSource = 'INTRO.png';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MainMenu_StartHere_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end