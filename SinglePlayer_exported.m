classdef SinglePlayer_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        tutorial                  matlab.ui.control.TextArea
        new_game_center           matlab.ui.control.Button
        ConfirmNewBetButton       matlab.ui.control.Button
        blackJack_counter         matlab.ui.control.EditField
        BLACKJACKSEditFieldLabel  matlab.ui.control.Label
        ties_counter              matlab.ui.control.EditField
        TIESEditFieldLabel        matlab.ui.control.Label
        losses_counter            matlab.ui.control.EditField
        LOSSESEditFieldLabel      matlab.ui.control.Label
        wins_counter              matlab.ui.control.EditField
        WINSEditFieldLabel        matlab.ui.control.Label
        Image2                    matlab.ui.control.Image
        Image                     matlab.ui.control.Image
        BetAmountLabel            matlab.ui.control.Label
        TutorialButton            matlab.ui.control.Button
        NewGameButton             matlab.ui.control.Button
        new_bet_field             matlab.ui.control.NumericEditField
        general_message           matlab.ui.control.Label
        playerTotalCount          matlab.ui.control.NumericEditField
        dealerTotalCount          matlab.ui.control.NumericEditField
        EnterbetamountLabel       matlab.ui.control.Label
        gameStatusText            matlab.ui.control.Label
        total_money_text          matlab.ui.control.TextArea
        TOTALLabel                matlab.ui.control.Label
        betText                   matlab.ui.control.TextArea
        Label                     matlab.ui.control.Label
        dealerCard6               matlab.ui.control.Image
        dealerCard5               matlab.ui.control.Image
        HiddenDealerCard          matlab.ui.control.Image
        dealerCard4               matlab.ui.control.Image
        dealerCard3               matlab.ui.control.Image
        dealerCard2               matlab.ui.control.Image
        dealerCard1               matlab.ui.control.Image
        playerCard6               matlab.ui.control.Image
        playerCard5               matlab.ui.control.Image
        playerCard4               matlab.ui.control.Image
        playerCard3               matlab.ui.control.Image
        playerCard2               matlab.ui.control.Image
        playerCard1               matlab.ui.control.Image
        chip_img                  matlab.ui.control.Image
        change_bet_button         matlab.ui.control.Button
        dealButton                matlab.ui.control.Button
        standButton               matlab.ui.control.Button
        hitButton                 matlab.ui.control.Button
        backgroundImg             matlab.ui.control.Image
        ignoreIt                  matlab.ui.control.UIAxes
    end

    
    %Written By Omar Alsabbagh

     properties (Access = private)
        Deck = 1:52;
        player_hand; 
        dealer_hand; 
        bet_amount = 0;
        player_first_card; % first card value for player
        player_second_card; % second card value for player
        player_new_card; % 3rd and the remaining cards
        dealer_first_card; % first card value for dealer
        dealer_second_card; % second card value for dealer
        dealer_new_card;
        wins; % number of wins
        blackjacks = 0; % number of blackjacks
        player_remaining_money; % total money
        player_next_draw = 3; % next card will be the 3rd card for the player
        dealer_next_draw  = 3; % next card will be the 3rd card for the dealer
        loss; % number of losses
        ties; % number of ties
        new_game = 1;
        initial_money; %used when new game button is pressed
    end
    
    methods (Access = private)
        
        function [card_name,updatedDeck,card_value] = draw_card(~,deck)
            updatedDeck = deck; 
            NamesFile = fopen('cardNames.txt','r');
            if NamesFile == -1, error('Cannot open the file!'); end
            
            cardIndex = randi([1, length(updatedDeck)]);
            for i = 1:updatedDeck(cardIndex)-1
                fgets(NamesFile);    
            end
            card_name = fscanf(NamesFile,'%s',1); %get the name of card
            card_value = fscanf(NamesFile,'%d',1); %get the value of card
            fclose(NamesFile);
            updatedDeck(cardIndex) = []; %delete the drawn card
        end
% ===========================================================================
function new_game_init(app)
            app.player_remaining_money = str2double(app.total_money_text.Value);
            bet_amnt = str2double(app.betText.Value);
            if bet_amnt > app.player_remaining_money
                app.general_message.Visible = 'on';
                app.general_message.Text = "Total Money Amount can't be less than Bet amount. Reseting bet Amount to $1";
                pause(4)
                app.general_message.Visible = 'off';
                app.bet_amount = 1;
                app.betText.Value = num2str(app.bet_amount);
            elseif app.player_remaining_money < 1
                app.general_message.Visible = 'on';
                app.general_message.Text = "Total Money Amount can't be less than 1. Reseting amount to 10";
                pause(4)
                app.general_message.Visible = 'off';
                app.player_remaining_money = 10;
                app.total_money_text.Value = num2str(app.player_remaining_money);
                
            end
            app.total_money_text.Editable = 'off';

            %reset stats
            app.wins = 0;
            app.loss = 0;
            app.ties = 0;
            app.blackjacks = 0;
            app.losses_counter.Value = num2str(0);
            app.wins_counter.Value = num2str(0);
            app.ties_counter.Value = num2str(0);
            app.blackJack_counter.Value = num2str(0);
            app.new_game = 0;
        end
% ===========================================================================
       
        function initialization(app)
            app.betText.Visible = 'on';
            app.chip_img.Visible = 'on';
            app.player_remaining_money = str2double(app.total_money_text.Value);
            app.bet_amount = str2double(app.betText.Value);
            if app.bet_amount < 1
                app.general_message.Visible = 'on';
                app.general_message.Text = "Bet Amount can't be less than 1. Reseting bet amount to 1";
                pause(4)
                app.general_message.Visible = 'off';
                app.bet_amount = 1;
                app.betText.Value = num2str(app.bet_amount);
            elseif app.bet_amount > app.player_remaining_money
                app.general_message.Visible = 'on';
                app.general_message.Text = "Bet Amount higher than remaining money. Reseting bet amount to 1";
                pause(4)
                app.general_message.Visible = 'off';
                app.bet_amount = 1;
                app.betText.Value = num2str(app.bet_amount);
            end
            
            app.dealerTotalCount.Visible = 'off';
            app.playerTotalCount.Visible = 'on';
            
            %load shuffle and deal sound effect
            [ya, Fs,] = audioread('shuffleSound.mp3');
            sound (ya, Fs);
            clear ya  Fs,
            pause(2)
            [ya,Fs] = audioread('dealCards.mp3');
            sound (ya, Fs);
            pause(1)

            app.hitButton.Visible = 'on';
            app.standButton.Visible = 'on';
            app.playerCard1.Visible = 'on';
            app.playerCard2.Visible = 'on';
            app.dealerCard1.Visible = 'on';
            app.HiddenDealerCard.Visible = 'on';
            app.change_bet_button.Visible = 'off';
            app.dealButton.Visible = 'off';

        end
% ===========================================================================
        function [player_status,dealer_status] = update_status(app,player_hand,dealer_hand)
            % possible outcomes:
            % 1: Black Jack
            % 2: bust
            % 3: Dummy (ie Nothing)

            narginchk(2, 3);
            if player_hand == 21  % player has black jack
                player_status = 1;
                app.blackjacks = app.blackjacks + 1;
                app.blackJack_counter.Value = num2str(app.blackjacks);
            elseif player_hand > 21 %If player has a bust
                player_status = 2;
            else 
                player_status = 3;
            end

            if nargin == 2,           dealer_status = 3;
            elseif dealer_hand == 21, dealer_status = 1;
            elseif dealer_hand > 21,  dealer_status = 2;
            else,                     dealer_status = 3;
            end
        end
% ===========================================================================

        function game_over = check_for_instant_win(app, player_status, dealer_status)
            narginchk(2, 3);
            game_over = 0;
            if nargin == 2, dealer_status = 3; end

            if (player_status == 2) || (dealer_status == 1)  % dealer has blackjack, or player is busted
                show_loss_screen(app); 
                game_over = 1;
            elseif (player_status == 1) || (dealer_status == 2)  % if player has blackjack, or dealer is busted
                show_win_screen(app);
                game_over = 1;
            
            end
        end
% ===========================================================================

        function show_win_screen(app)
            app.standButton.Visible = 'off';
            app.hitButton.Visible = 'off';
            show_dealer_hand(app);
            app.player_remaining_money = app.player_remaining_money + app.bet_amount;
            app.total_money_text.Value = num2str(app.player_remaining_money);
            app.gameStatusText.Text = "YOU WIN!";
            app.gameStatusText.Visible = 'on';
            [ya, Fs,] = audioread('YouWin.mp3');
            sound (ya, Fs);  pause(3);
            app.wins = app.wins + 1;
            app.wins_counter.Value = num2str(app.wins);
            pause(1);
            app.gameStatusText.Text = "";
            app.gameStatusText.Visible = 'off';
            reset(app);
        end
% ===========================================================================
        function show_loss_screen(app)
            app.standButton.Visible = 'off';
            app.hitButton.Visible = 'off';
            show_dealer_hand(app);
            app.player_remaining_money = app.player_remaining_money - app.bet_amount;
            app.total_money_text.Value = num2str(app.player_remaining_money);
            app.gameStatusText.Text = "YOU LOSE";
            app.gameStatusText.Visible = 'on';
            [ya, Fs,] = audioread('YouLose.mp3');
            sound (ya, Fs);  pause(3);
            app.loss = app.loss + 1;
            app.losses_counter.Value = num2str(app.loss);
            pause(1);
            app.gameStatusText.Text = "";
            app.gameStatusText.Visible = 'off';
            reset(app); 
        end
% ===========================================================================
        function show_dealer_hand(app)
            app.dealerTotalCount.Value = app.dealer_hand;
            app.dealerTotalCount.Visible = 'on';
            app.HiddenDealerCard.Visible = 'off';
            app.dealerCard2.Visible = 'on';
        end 
% ===========================================================================
        
        function reset(app)
            if app.player_remaining_money <= 0 
                app.gameStatusText.Text = "GAME OVER. You run out of Money";
                app.gameStatusText.Visible = 'on';
                pause(4);
                app.gameStatusText.Visible = 'off';
                app.new_game_center.Visible = 'on';
                app.chip_img.Visible = 'off';
            else
                app.gameStatusText.Visible = 'off';
                app.standButton.Visible = 'off';
                app.hitButton.Visible = 'off';
                app.general_message.Visible = 'off';
                pause(1);
                app.dealButton.Visible = 'on';
                app.change_bet_button.Visible = 'on';
                app.playerCard1.Visible = 'off';
                app.playerCard2.Visible = 'off';
                app.playerCard3.Visible = 'off';
                app.playerCard4.Visible = 'off';
                app.playerCard5.Visible = 'off';
                
                app.dealerCard1.Visible = 'off';
                app.dealerCard2.Visible = 'off';
                app.dealerCard3.Visible = 'off';
                app.dealerCard4.Visible = 'off';
                app.dealerCard5.Visible = 'off';
                app.HiddenDealerCard.Visible = 'off';
                app.dealerTotalCount.Value = 0;
                app.playerTotalCount.Value = 0;
                app.dealerTotalCount.Visible = 'off';
                app.chip_img.Visible = 'off';
                app.player_next_draw = 3;
                app.dealer_next_draw = 3;
                app.player_hand = 0;
                app.dealer_hand = 0;
                app.Deck = 1:52;
            end
        end
% ===========================================================================
    end
    % ====== end of method access ==========

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: change_bet_button
        function changeBetPushed(app, event)
            app.EnterbetamountLabel.Visible = 'on';
            app.betText.Editable = 'on';
            app.ConfirmNewBetButton.Visible = 'on';
            app.dealButton.Visible = 'off';
        end

        % Button pushed function: ConfirmNewBetButton
        function ConfirmNewBetButtonPushed(app, event)
            
            app.player_remaining_money = str2double(app.total_money_text.Value);
            if isnan(str2double(app.betText.Value))
                app.general_message.Visible = 'on';
                app.general_message.Text = "Bet amount can't contain letters or characters. resetting bet amount to $1";
                pause(3)
                app.betText.Value = num2str(1);
                app.general_message.Visible = 'off';
            end
            app.bet_amount = str2double(app.betText.Value);
            
            if app.bet_amount > app.player_remaining_money
                app.general_message.Visible = 'on';
                app.general_message.Text = "Bet amount can't be more than total amount of money. setting bet amount to $1";
                pause(3)
                app.bet_amount = 1;
                app.general_message.Visible = 'off';
            
            elseif app.bet_amount < 1
                app.general_message.Visible = 'on';
                app.general_message.Text = "Bet amount can't be less than $1. setting bet amount to $1";
                pause(3)
                app.bet_amount = 1;
                app.general_message.Visible = 'off';
            end
            app.betText.Value = num2str(app.bet_amount);
            app.EnterbetamountLabel.Visible = 'off';
            app.betText.Editable = 'off';
            app.ConfirmNewBetButton.Visible = 'off';
            app.dealButton.Visible = 'on';
            
        end

        % Button pushed function: dealButton
        function dealPushed(app, event)
            if app.new_game, new_game_init(app); end
            initialization(app);
            deck = app.Deck;
            [card_name,deck, app.player_first_card] = draw_card(app,deck); %draw first card
            app.playerCard1.ImageSource = card_name; %get the image of the card
            [card_name,deck,app.player_second_card] = draw_card(app,deck); %draw second card
            app.playerCard2.ImageSource = card_name;

            %An ace's value is 11 unless this would 
            %cause the player to bust, in which case it is worth 1
            total = app.player_first_card + app.player_second_card;
            if (total > 21)
                if app.player_first_card == 11,   app.player_first_card = 1; end
                if app.player_second_card == 11,  app.player_second_card = 1; end
            end
            app.player_hand = app.player_first_card + app.player_second_card;
            app.playerTotalCount.Value = app.player_hand;
           
            [card_name,deck,app.dealer_first_card] = draw_card(app,deck);
            app.dealerCard1.ImageSource = card_name;
            [card_name,deck,app.dealer_second_card] = draw_card(app,deck);
            app.dealerCard2.ImageSource = card_name;
            app.Deck = deck;
            total  = app.dealer_first_card + app.dealer_second_card;
            if (total > 21)
                if app.dealer_first_card == 11,  app.dealer_first_card = 1; end
                if app.dealer_second_card == 11,  app.dealer_second_card = 1; end
            end
            app.dealer_hand = app.dealer_first_card + app.dealer_second_card;
            app.initial_money = app.player_remaining_money;
    
            [player_status,dealer_status] = update_status(app,app.player_hand,app.dealer_hand);
            check_for_instant_win(app, player_status, dealer_status);
            
        end

        % Button pushed function: hitButton
        function hitPushed(app, event)
            count = app.player_next_draw;
            deck = app.Deck;
            [card_name, deck, app.player_new_card] = draw_card(app,deck);
            switch(app.player_next_draw)
                case 3
                    app.playerCard3.Visible = 'on';
                    app.playerCard3.ImageSource = card_name;
                    count = count + 1;
                case 4
                    app.playerCard4.Visible = 'on';
                    app.playerCard4.ImageSource = card_name;
                    count = count + 1;
                case 5
                    app.playerCard5.Visible = 'on';
                    app.playerCard5.ImageSource = card_name;
                    count = count + 1;
                otherwise
                    standPushed(app);  %you can't draw more than 5 cards
            end
            app.player_next_draw = count;
            app.Deck = deck;
            total = app.player_hand + app.player_new_card;
            % ACES 1 OR 11
            if (total > 21) && (app.player_new_card == 11)
                app.player_new_card = 1;
            end
            app.player_hand = app.player_hand + app.player_new_card;
            app.playerTotalCount.Value = app.player_hand;
            [player_status,~] = update_status(app,app.player_hand,app.dealer_hand);
            check_for_instant_win(app, player_status);
            
        end

        % Button pushed function: standButton
        function standPushed(app, event)
           app.standButton.Visible = 'off';
           app.hitButton.Visible = 'off';
           
            while app.dealer_hand < 17
                count = app.dealer_next_draw;
                deck = app.Deck;
                [card_name,deck,app.dealer_new_card] = draw_card(app,deck);
                switch count
                    case 3
                        app.dealerCard3.Visible = 'on';
                        app.dealerCard3.ImageSource = card_name;
                        count = count + 1;
                    case 4
                        app.dealerCard4.Visible = 'on';
                        app.dealerCard4.ImageSource = card_name;
                        count = count + 1;
                    case 5
                        app.dealerCard5.Visible = 'on';
                        app.dealerCard5.ImageSource = card_name;
                        count = count + 1;
                end
                app.dealer_next_draw = count;
                app.Deck = deck;
                total = app.dealer_hand + app.dealer_new_card;
                % ACES 1 OR 11
                if (total > 21) && (app.dealer_new_card == 11)
                    app.dealer_new_card = 1;
                end
                app.dealer_hand = app.dealer_hand + app.dealer_new_card;
            end % == end of while == 
            pause(0.5);
            show_dealer_hand(app);
            [player_status,dealer_status] = update_status(app,app.player_hand,app.dealer_hand);
            if check_for_instant_win(app, player_status, dealer_status)
            elseif app.dealer_hand == app.player_hand % Tie
                app.gameStatusText.Text = "TIE";
                app.gameStatusText.Visible = 'on';
                
                pause(2);
                app.gameStatusText.Text = "";
                app.ties = app.ties + 1;
                app.ties_counter.Value = num2str(app.ties);
                reset(app);
            elseif app.dealer_hand > app.player_hand % dealer wins
                show_loss_screen(app)
            elseif app.player_hand > app.dealer_hand % player wins
                show_win_screen(app)
            end
        

        end

        % Button pushed function: NewGameButton, new_game_center
        function NewGameButtonPushed(app, event)
            app.total_money_text.Editable = 'on';
            app.player_remaining_money = 1000;
            app.total_money_text.Value = num2str(app.player_remaining_money);
            reset(app);
            app.new_game = 1;
            app.new_game_center.Visible = 'off';
            app.losses_counter.Value = num2str(0);
            app.wins_counter.Value = num2str(0);
            app.ties_counter.Value = num2str(0);
            app.blackJack_counter.Value = num2str(0);

        end

        % Button pushed function: TutorialButton
        function TutorialButtonPushed(app, event)
            if app.tutorial.Visible == 1
                app.tutorial.Visible = 'off';
                app.TutorialButton.Text = 'Tutorial';
            else
                app.tutorial.Visible = 'on';
                app.TutorialButton.Text = 'Close Tutorial';
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.149 0.149 0.149];
            app.UIFigure.Colormap = [0.2431 0.149 0.6588;0.2431 0.1529 0.6745;0.2471 0.1569 0.6863;0.2471 0.1608 0.698;0.251 0.1647 0.7059;0.251 0.1686 0.7176;0.2549 0.1725 0.7294;0.2549 0.1765 0.7412;0.2588 0.1804 0.749;0.2588 0.1843 0.7608;0.2627 0.1882 0.7725;0.2627 0.1922 0.7843;0.2627 0.1961 0.7922;0.2667 0.2 0.8039;0.2667 0.2039 0.8157;0.2706 0.2078 0.8235;0.2706 0.2157 0.8353;0.2706 0.2196 0.8431;0.2745 0.2235 0.851;0.2745 0.2275 0.8627;0.2745 0.2314 0.8706;0.2745 0.2392 0.8784;0.2784 0.2431 0.8824;0.2784 0.2471 0.8902;0.2784 0.2549 0.898;0.2784 0.2588 0.902;0.2784 0.2667 0.9098;0.2784 0.2706 0.9137;0.2784 0.2745 0.9216;0.2824 0.2824 0.9255;0.2824 0.2863 0.9294;0.2824 0.2941 0.9333;0.2824 0.298 0.9412;0.2824 0.3059 0.9451;0.2824 0.3098 0.949;0.2824 0.3137 0.9529;0.2824 0.3216 0.9569;0.2824 0.3255 0.9608;0.2824 0.3294 0.9647;0.2784 0.3373 0.9686;0.2784 0.3412 0.9686;0.2784 0.349 0.9725;0.2784 0.3529 0.9765;0.2784 0.3569 0.9804;0.2784 0.3647 0.9804;0.2745 0.3686 0.9843;0.2745 0.3765 0.9843;0.2745 0.3804 0.9882;0.2706 0.3843 0.9882;0.2706 0.3922 0.9922;0.2667 0.3961 0.9922;0.2627 0.4039 0.9922;0.2627 0.4078 0.9961;0.2588 0.4157 0.9961;0.2549 0.4196 0.9961;0.251 0.4275 0.9961;0.2471 0.4314 1;0.2431 0.4392 1;0.2353 0.4431 1;0.2314 0.451 1;0.2235 0.4549 1;0.2196 0.4627 0.9961;0.2118 0.4667 0.9961;0.2078 0.4745 0.9922;0.2 0.4784 0.9922;0.1961 0.4863 0.9882;0.1922 0.4902 0.9882;0.1882 0.498 0.9843;0.1843 0.502 0.9804;0.1843 0.5098 0.9804;0.1804 0.5137 0.9765;0.1804 0.5176 0.9725;0.1804 0.5255 0.9725;0.1804 0.5294 0.9686;0.1765 0.5333 0.9647;0.1765 0.5412 0.9608;0.1765 0.5451 0.9569;0.1765 0.549 0.9529;0.1765 0.5569 0.949;0.1725 0.5608 0.9451;0.1725 0.5647 0.9412;0.1686 0.5686 0.9373;0.1647 0.5765 0.9333;0.1608 0.5804 0.9294;0.1569 0.5843 0.9255;0.1529 0.5922 0.9216;0.1529 0.5961 0.9176;0.149 0.6 0.9137;0.149 0.6039 0.9098;0.1451 0.6078 0.9098;0.1451 0.6118 0.9059;0.1412 0.6196 0.902;0.1412 0.6235 0.898;0.1373 0.6275 0.898;0.1373 0.6314 0.8941;0.1333 0.6353 0.8941;0.1294 0.6392 0.8902;0.1255 0.6471 0.8902;0.1216 0.651 0.8863;0.1176 0.6549 0.8824;0.1137 0.6588 0.8824;0.1137 0.6627 0.8784;0.1098 0.6667 0.8745;0.1059 0.6706 0.8706;0.102 0.6745 0.8667;0.098 0.6784 0.8627;0.0902 0.6824 0.8549;0.0863 0.6863 0.851;0.0784 0.6902 0.8471;0.0706 0.6941 0.8392;0.0627 0.698 0.8353;0.0549 0.702 0.8314;0.0431 0.702 0.8235;0.0314 0.7059 0.8196;0.0235 0.7098 0.8118;0.0157 0.7137 0.8078;0.0078 0.7176 0.8;0.0039 0.7176 0.7922;0 0.7216 0.7882;0 0.7255 0.7804;0 0.7294 0.7765;0.0039 0.7294 0.7686;0.0078 0.7333 0.7608;0.0157 0.7333 0.7569;0.0235 0.7373 0.749;0.0353 0.7412 0.7412;0.051 0.7412 0.7373;0.0627 0.7451 0.7294;0.0784 0.7451 0.7216;0.0902 0.749 0.7137;0.102 0.7529 0.7098;0.1137 0.7529 0.702;0.1255 0.7569 0.6941;0.1373 0.7569 0.6863;0.1451 0.7608 0.6824;0.1529 0.7608 0.6745;0.1608 0.7647 0.6667;0.1686 0.7647 0.6588;0.1725 0.7686 0.651;0.1804 0.7686 0.6471;0.1843 0.7725 0.6392;0.1922 0.7725 0.6314;0.1961 0.7765 0.6235;0.2 0.7804 0.6157;0.2078 0.7804 0.6078;0.2118 0.7843 0.6;0.2196 0.7843 0.5882;0.2235 0.7882 0.5804;0.2314 0.7882 0.5725;0.2392 0.7922 0.5647;0.251 0.7922 0.5529;0.2588 0.7922 0.5451;0.2706 0.7961 0.5373;0.2824 0.7961 0.5255;0.2941 0.7961 0.5176;0.3059 0.8 0.5059;0.3176 0.8 0.498;0.3294 0.8 0.4863;0.3412 0.8 0.4784;0.3529 0.8 0.4667;0.3686 0.8039 0.4549;0.3804 0.8039 0.4471;0.3922 0.8039 0.4353;0.4039 0.8039 0.4235;0.4196 0.8039 0.4118;0.4314 0.8039 0.4;0.4471 0.8039 0.3922;0.4627 0.8 0.3804;0.4745 0.8 0.3686;0.4902 0.8 0.3569;0.5059 0.8 0.349;0.5176 0.8 0.3373;0.5333 0.7961 0.3255;0.5451 0.7961 0.3176;0.5608 0.7961 0.3059;0.5765 0.7922 0.2941;0.5882 0.7922 0.2824;0.6039 0.7882 0.2745;0.6157 0.7882 0.2627;0.6314 0.7843 0.251;0.6431 0.7843 0.2431;0.6549 0.7804 0.2314;0.6706 0.7804 0.2235;0.6824 0.7765 0.2157;0.698 0.7765 0.2078;0.7098 0.7725 0.2;0.7216 0.7686 0.1922;0.7333 0.7686 0.1843;0.7451 0.7647 0.1765;0.7608 0.7647 0.1725;0.7725 0.7608 0.1647;0.7843 0.7569 0.1608;0.7961 0.7569 0.1569;0.8078 0.7529 0.1529;0.8157 0.749 0.1529;0.8275 0.749 0.1529;0.8392 0.7451 0.1529;0.851 0.7451 0.1569;0.8588 0.7412 0.1569;0.8706 0.7373 0.1608;0.8824 0.7373 0.1647;0.8902 0.7373 0.1686;0.902 0.7333 0.1765;0.9098 0.7333 0.1804;0.9176 0.7294 0.1882;0.9255 0.7294 0.1961;0.9373 0.7294 0.2078;0.9451 0.7294 0.2157;0.9529 0.7294 0.2235;0.9608 0.7294 0.2314;0.9686 0.7294 0.2392;0.9765 0.7294 0.2431;0.9843 0.7333 0.2431;0.9882 0.7373 0.2431;0.9961 0.7412 0.2392;0.9961 0.7451 0.2353;0.9961 0.7529 0.2314;0.9961 0.7569 0.2275;0.9961 0.7608 0.2235;0.9961 0.7686 0.2196;0.9961 0.7725 0.2157;0.9961 0.7804 0.2078;0.9961 0.7843 0.2039;0.9961 0.7922 0.2;0.9922 0.7961 0.1961;0.9922 0.8039 0.1922;0.9922 0.8078 0.1922;0.9882 0.8157 0.1882;0.9843 0.8235 0.1843;0.9843 0.8275 0.1804;0.9804 0.8353 0.1804;0.9765 0.8392 0.1765;0.9765 0.8471 0.1725;0.9725 0.851 0.1686;0.9686 0.8588 0.1647;0.9686 0.8667 0.1647;0.9647 0.8706 0.1608;0.9647 0.8784 0.1569;0.9608 0.8824 0.1569;0.9608 0.8902 0.1529;0.9608 0.898 0.149;0.9608 0.902 0.149;0.9608 0.9098 0.1451;0.9608 0.9137 0.1412;0.9608 0.9216 0.1373;0.9608 0.9255 0.1333;0.9608 0.9333 0.1294;0.9647 0.9373 0.1255;0.9647 0.9451 0.1216;0.9647 0.949 0.1176;0.9686 0.9569 0.1098;0.9686 0.9608 0.1059;0.9725 0.9686 0.102;0.9725 0.9725 0.0941;0.9765 0.9765 0.0863;0.9765 0.9843 0.0824];
            app.UIFigure.Position = [100 100 1000 750];
            app.UIFigure.Name = 'UI Figure';

            % Create ignoreIt
            app.ignoreIt = uiaxes(app.UIFigure);
            app.ignoreIt.Toolbar.Visible = 'off';
            app.ignoreIt.FontName = 'Times New Roman';
            app.ignoreIt.FontWeight = 'bold';
            app.ignoreIt.Colormap = [0.2431 0.149 0.6588;0.2431 0.1529 0.6745;0.2471 0.1569 0.6863;0.2471 0.1608 0.698;0.251 0.1647 0.7059;0.251 0.1686 0.7176;0.2549 0.1725 0.7294;0.2549 0.1765 0.7412;0.2588 0.1804 0.749;0.2588 0.1843 0.7608;0.2627 0.1882 0.7725;0.2627 0.1922 0.7843;0.2627 0.1961 0.7922;0.2667 0.2 0.8039;0.2667 0.2039 0.8157;0.2706 0.2078 0.8235;0.2706 0.2157 0.8353;0.2706 0.2196 0.8431;0.2745 0.2235 0.851;0.2745 0.2275 0.8627;0.2745 0.2314 0.8706;0.2745 0.2392 0.8784;0.2784 0.2431 0.8824;0.2784 0.2471 0.8902;0.2784 0.2549 0.898;0.2784 0.2588 0.902;0.2784 0.2667 0.9098;0.2784 0.2706 0.9137;0.2784 0.2745 0.9216;0.2824 0.2824 0.9255;0.2824 0.2863 0.9294;0.2824 0.2941 0.9333;0.2824 0.298 0.9412;0.2824 0.3059 0.9451;0.2824 0.3098 0.949;0.2824 0.3137 0.9529;0.2824 0.3216 0.9569;0.2824 0.3255 0.9608;0.2824 0.3294 0.9647;0.2784 0.3373 0.9686;0.2784 0.3412 0.9686;0.2784 0.349 0.9725;0.2784 0.3529 0.9765;0.2784 0.3569 0.9804;0.2784 0.3647 0.9804;0.2745 0.3686 0.9843;0.2745 0.3765 0.9843;0.2745 0.3804 0.9882;0.2706 0.3843 0.9882;0.2706 0.3922 0.9922;0.2667 0.3961 0.9922;0.2627 0.4039 0.9922;0.2627 0.4078 0.9961;0.2588 0.4157 0.9961;0.2549 0.4196 0.9961;0.251 0.4275 0.9961;0.2471 0.4314 1;0.2431 0.4392 1;0.2353 0.4431 1;0.2314 0.451 1;0.2235 0.4549 1;0.2196 0.4627 0.9961;0.2118 0.4667 0.9961;0.2078 0.4745 0.9922;0.2 0.4784 0.9922;0.1961 0.4863 0.9882;0.1922 0.4902 0.9882;0.1882 0.498 0.9843;0.1843 0.502 0.9804;0.1843 0.5098 0.9804;0.1804 0.5137 0.9765;0.1804 0.5176 0.9725;0.1804 0.5255 0.9725;0.1804 0.5294 0.9686;0.1765 0.5333 0.9647;0.1765 0.5412 0.9608;0.1765 0.5451 0.9569;0.1765 0.549 0.9529;0.1765 0.5569 0.949;0.1725 0.5608 0.9451;0.1725 0.5647 0.9412;0.1686 0.5686 0.9373;0.1647 0.5765 0.9333;0.1608 0.5804 0.9294;0.1569 0.5843 0.9255;0.1529 0.5922 0.9216;0.1529 0.5961 0.9176;0.149 0.6 0.9137;0.149 0.6039 0.9098;0.1451 0.6078 0.9098;0.1451 0.6118 0.9059;0.1412 0.6196 0.902;0.1412 0.6235 0.898;0.1373 0.6275 0.898;0.1373 0.6314 0.8941;0.1333 0.6353 0.8941;0.1294 0.6392 0.8902;0.1255 0.6471 0.8902;0.1216 0.651 0.8863;0.1176 0.6549 0.8824;0.1137 0.6588 0.8824;0.1137 0.6627 0.8784;0.1098 0.6667 0.8745;0.1059 0.6706 0.8706;0.102 0.6745 0.8667;0.098 0.6784 0.8627;0.0902 0.6824 0.8549;0.0863 0.6863 0.851;0.0784 0.6902 0.8471;0.0706 0.6941 0.8392;0.0627 0.698 0.8353;0.0549 0.702 0.8314;0.0431 0.702 0.8235;0.0314 0.7059 0.8196;0.0235 0.7098 0.8118;0.0157 0.7137 0.8078;0.0078 0.7176 0.8;0.0039 0.7176 0.7922;0 0.7216 0.7882;0 0.7255 0.7804;0 0.7294 0.7765;0.0039 0.7294 0.7686;0.0078 0.7333 0.7608;0.0157 0.7333 0.7569;0.0235 0.7373 0.749;0.0353 0.7412 0.7412;0.051 0.7412 0.7373;0.0627 0.7451 0.7294;0.0784 0.7451 0.7216;0.0902 0.749 0.7137;0.102 0.7529 0.7098;0.1137 0.7529 0.702;0.1255 0.7569 0.6941;0.1373 0.7569 0.6863;0.1451 0.7608 0.6824;0.1529 0.7608 0.6745;0.1608 0.7647 0.6667;0.1686 0.7647 0.6588;0.1725 0.7686 0.651;0.1804 0.7686 0.6471;0.1843 0.7725 0.6392;0.1922 0.7725 0.6314;0.1961 0.7765 0.6235;0.2 0.7804 0.6157;0.2078 0.7804 0.6078;0.2118 0.7843 0.6;0.2196 0.7843 0.5882;0.2235 0.7882 0.5804;0.2314 0.7882 0.5725;0.2392 0.7922 0.5647;0.251 0.7922 0.5529;0.2588 0.7922 0.5451;0.2706 0.7961 0.5373;0.2824 0.7961 0.5255;0.2941 0.7961 0.5176;0.3059 0.8 0.5059;0.3176 0.8 0.498;0.3294 0.8 0.4863;0.3412 0.8 0.4784;0.3529 0.8 0.4667;0.3686 0.8039 0.4549;0.3804 0.8039 0.4471;0.3922 0.8039 0.4353;0.4039 0.8039 0.4235;0.4196 0.8039 0.4118;0.4314 0.8039 0.4;0.4471 0.8039 0.3922;0.4627 0.8 0.3804;0.4745 0.8 0.3686;0.4902 0.8 0.3569;0.5059 0.8 0.349;0.5176 0.8 0.3373;0.5333 0.7961 0.3255;0.5451 0.7961 0.3176;0.5608 0.7961 0.3059;0.5765 0.7922 0.2941;0.5882 0.7922 0.2824;0.6039 0.7882 0.2745;0.6157 0.7882 0.2627;0.6314 0.7843 0.251;0.6431 0.7843 0.2431;0.6549 0.7804 0.2314;0.6706 0.7804 0.2235;0.6824 0.7765 0.2157;0.698 0.7765 0.2078;0.7098 0.7725 0.2;0.7216 0.7686 0.1922;0.7333 0.7686 0.1843;0.7451 0.7647 0.1765;0.7608 0.7647 0.1725;0.7725 0.7608 0.1647;0.7843 0.7569 0.1608;0.7961 0.7569 0.1569;0.8078 0.7529 0.1529;0.8157 0.749 0.1529;0.8275 0.749 0.1529;0.8392 0.7451 0.1529;0.851 0.7451 0.1569;0.8588 0.7412 0.1569;0.8706 0.7373 0.1608;0.8824 0.7373 0.1647;0.8902 0.7373 0.1686;0.902 0.7333 0.1765;0.9098 0.7333 0.1804;0.9176 0.7294 0.1882;0.9255 0.7294 0.1961;0.9373 0.7294 0.2078;0.9451 0.7294 0.2157;0.9529 0.7294 0.2235;0.9608 0.7294 0.2314;0.9686 0.7294 0.2392;0.9765 0.7294 0.2431;0.9843 0.7333 0.2431;0.9882 0.7373 0.2431;0.9961 0.7412 0.2392;0.9961 0.7451 0.2353;0.9961 0.7529 0.2314;0.9961 0.7569 0.2275;0.9961 0.7608 0.2235;0.9961 0.7686 0.2196;0.9961 0.7725 0.2157;0.9961 0.7804 0.2078;0.9961 0.7843 0.2039;0.9961 0.7922 0.2;0.9922 0.7961 0.1961;0.9922 0.8039 0.1922;0.9922 0.8078 0.1922;0.9882 0.8157 0.1882;0.9843 0.8235 0.1843;0.9843 0.8275 0.1804;0.9804 0.8353 0.1804;0.9765 0.8392 0.1765;0.9765 0.8471 0.1725;0.9725 0.851 0.1686;0.9686 0.8588 0.1647;0.9686 0.8667 0.1647;0.9647 0.8706 0.1608;0.9647 0.8784 0.1569;0.9608 0.8824 0.1569;0.9608 0.8902 0.1529;0.9608 0.898 0.149;0.9608 0.902 0.149;0.9608 0.9098 0.1451;0.9608 0.9137 0.1412;0.9608 0.9216 0.1373;0.9608 0.9255 0.1333;0.9608 0.9333 0.1294;0.9647 0.9373 0.1255;0.9647 0.9451 0.1216;0.9647 0.949 0.1176;0.9686 0.9569 0.1098;0.9686 0.9608 0.1059;0.9725 0.9686 0.102;0.9725 0.9725 0.0941;0.9765 0.9765 0.0863;0.9765 0.9843 0.0824];
            app.ignoreIt.XTick = [];
            app.ignoreIt.YTick = [];
            app.ignoreIt.Visible = 'off';
            app.ignoreIt.HandleVisibility = 'off';
            app.ignoreIt.Interruptible = 'off';
            app.ignoreIt.HitTest = 'off';
            app.ignoreIt.Position = [192 391 0 0];

            % Create backgroundImg
            app.backgroundImg = uiimage(app.UIFigure);
            app.backgroundImg.ScaleMethod = 'stretch';
            app.backgroundImg.Position = [1 1 797 750];
            app.backgroundImg.ImageSource = 'poker_table.jpg';

            % Create hitButton
            app.hitButton = uibutton(app.UIFigure, 'push');
            app.hitButton.ButtonPushedFcn = createCallbackFcn(app, @hitPushed, true);
            app.hitButton.BackgroundColor = [1 1 1];
            app.hitButton.FontName = 'Times New Roman';
            app.hitButton.FontSize = 24;
            app.hitButton.FontWeight = 'bold';
            app.hitButton.FontColor = [1 0 0];
            app.hitButton.Visible = 'off';
            app.hitButton.Position = [18 13 95 91];
            app.hitButton.Text = {'HIT'; ''};

            % Create standButton
            app.standButton = uibutton(app.UIFigure, 'push');
            app.standButton.ButtonPushedFcn = createCallbackFcn(app, @standPushed, true);
            app.standButton.BackgroundColor = [0.902 0.902 0.902];
            app.standButton.FontName = 'Times New Roman';
            app.standButton.FontSize = 24;
            app.standButton.FontWeight = 'bold';
            app.standButton.FontColor = [1 0 0];
            app.standButton.Visible = 'off';
            app.standButton.Position = [689 13 95 91];
            app.standButton.Text = 'STAND';

            % Create dealButton
            app.dealButton = uibutton(app.UIFigure, 'push');
            app.dealButton.ButtonPushedFcn = createCallbackFcn(app, @dealPushed, true);
            app.dealButton.BackgroundColor = [0.6353 0.0784 0.1843];
            app.dealButton.FontName = 'Times New Roman';
            app.dealButton.FontSize = 24;
            app.dealButton.FontWeight = 'bold';
            app.dealButton.FontColor = [0.9412 0.9412 0.9412];
            app.dealButton.Position = [382 179 125 39];
            app.dealButton.Text = 'DEAL';

            % Create change_bet_button
            app.change_bet_button = uibutton(app.UIFigure, 'push');
            app.change_bet_button.ButtonPushedFcn = createCallbackFcn(app, @changeBetPushed, true);
            app.change_bet_button.BackgroundColor = [0 0 1];
            app.change_bet_button.FontName = 'Times New Roman';
            app.change_bet_button.FontSize = 14;
            app.change_bet_button.FontWeight = 'bold';
            app.change_bet_button.FontColor = [0.9412 0.9412 0.9412];
            app.change_bet_button.Position = [223 179 134 39];
            app.change_bet_button.Text = 'CHANGE BET';

            % Create chip_img
            app.chip_img = uiimage(app.UIFigure);
            app.chip_img.Visible = 'off';
            app.chip_img.Position = [324 350 143 95];
            app.chip_img.ImageSource = 'pokerChips.jpg';

            % Create playerCard1
            app.playerCard1 = uiimage(app.UIFigure);
            app.playerCard1.Visible = 'off';
            app.playerCard1.Position = [211 92 71 76];
            app.playerCard1.ImageSource = 'front.png';

            % Create playerCard2
            app.playerCard2 = uiimage(app.UIFigure);
            app.playerCard2.Visible = 'off';
            app.playerCard2.Position = [262 92 71 76];
            app.playerCard2.ImageSource = 'front.png';

            % Create playerCard3
            app.playerCard3 = uiimage(app.UIFigure);
            app.playerCard3.Visible = 'off';
            app.playerCard3.Position = [313 92 71 76];
            app.playerCard3.ImageSource = 'front.png';

            % Create playerCard4
            app.playerCard4 = uiimage(app.UIFigure);
            app.playerCard4.Visible = 'off';
            app.playerCard4.Position = [364 92 71 76];
            app.playerCard4.ImageSource = 'front.png';

            % Create playerCard5
            app.playerCard5 = uiimage(app.UIFigure);
            app.playerCard5.Visible = 'off';
            app.playerCard5.Position = [415 92 71 76];
            app.playerCard5.ImageSource = 'front.png';

            % Create playerCard6
            app.playerCard6 = uiimage(app.UIFigure);
            app.playerCard6.Visible = 'off';
            app.playerCard6.Position = [466 92 71 76];
            app.playerCard6.ImageSource = 'front.png';

            % Create dealerCard1
            app.dealerCard1 = uiimage(app.UIFigure);
            app.dealerCard1.Visible = 'off';
            app.dealerCard1.Position = [244 648 71 76];
            app.dealerCard1.ImageSource = 'front.png';

            % Create dealerCard2
            app.dealerCard2 = uiimage(app.UIFigure);
            app.dealerCard2.Visible = 'off';
            app.dealerCard2.Position = [295 648 71 76];
            app.dealerCard2.ImageSource = 'front.png';

            % Create dealerCard3
            app.dealerCard3 = uiimage(app.UIFigure);
            app.dealerCard3.Visible = 'off';
            app.dealerCard3.Position = [346 648 71 76];
            app.dealerCard3.ImageSource = 'front.png';

            % Create dealerCard4
            app.dealerCard4 = uiimage(app.UIFigure);
            app.dealerCard4.Visible = 'off';
            app.dealerCard4.Position = [397 648 71 76];
            app.dealerCard4.ImageSource = 'front.png';

            % Create HiddenDealerCard
            app.HiddenDealerCard = uiimage(app.UIFigure);
            app.HiddenDealerCard.Visible = 'off';
            app.HiddenDealerCard.Position = [296 648 69 76];
            app.HiddenDealerCard.ImageSource = 'card_back.png';

            % Create dealerCard5
            app.dealerCard5 = uiimage(app.UIFigure);
            app.dealerCard5.Visible = 'off';
            app.dealerCard5.Position = [448 648 71 76];
            app.dealerCard5.ImageSource = 'front.png';

            % Create dealerCard6
            app.dealerCard6 = uiimage(app.UIFigure);
            app.dealerCard6.Visible = 'off';
            app.dealerCard6.Position = [500 648 71 76];
            app.dealerCard6.ImageSource = 'front.png';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.VerticalAlignment = 'top';
            app.Label.FontName = 'Times New Roman';
            app.Label.FontSize = 16;
            app.Label.FontWeight = 'bold';
            app.Label.FontColor = [0.9412 0.9412 0.9412];
            app.Label.Position = [79 391 29 22];
            app.Label.Text = '$';

            % Create betText
            app.betText = uitextarea(app.UIFigure);
            app.betText.Editable = 'off';
            app.betText.HorizontalAlignment = 'center';
            app.betText.FontName = 'Times New Roman';
            app.betText.FontSize = 16;
            app.betText.FontWeight = 'bold';
            app.betText.Position = [110 390 55 25];
            app.betText.Value = {'50'};

            % Create TOTALLabel
            app.TOTALLabel = uilabel(app.UIFigure);
            app.TOTALLabel.HorizontalAlignment = 'right';
            app.TOTALLabel.VerticalAlignment = 'top';
            app.TOTALLabel.FontName = 'Times New Roman';
            app.TOTALLabel.FontSize = 16;
            app.TOTALLabel.FontWeight = 'bold';
            app.TOTALLabel.FontColor = [0.9412 0.9412 0.9412];
            app.TOTALLabel.Position = [252 36 72 22];
            app.TOTALLabel.Text = 'TOTAL $';

            % Create total_money_text
            app.total_money_text = uitextarea(app.UIFigure);
            app.total_money_text.HorizontalAlignment = 'center';
            app.total_money_text.FontName = 'Times New Roman';
            app.total_money_text.FontSize = 16;
            app.total_money_text.FontWeight = 'bold';
            app.total_money_text.FontColor = [1 0 0];
            app.total_money_text.BackgroundColor = [0.0588 1 1];
            app.total_money_text.Position = [326 35 152 25];
            app.total_money_text.Value = {'1000'};

            % Create gameStatusText
            app.gameStatusText = uilabel(app.UIFigure);
            app.gameStatusText.HorizontalAlignment = 'center';
            app.gameStatusText.FontName = 'Times New Roman';
            app.gameStatusText.FontSize = 45;
            app.gameStatusText.FontWeight = 'bold';
            app.gameStatusText.FontColor = [0.6353 0.0784 0.1843];
            app.gameStatusText.Visible = 'off';
            app.gameStatusText.Position = [-19 480 826 61];
            app.gameStatusText.Text = '';

            % Create EnterbetamountLabel
            app.EnterbetamountLabel = uilabel(app.UIFigure);
            app.EnterbetamountLabel.BackgroundColor = [1 1 1];
            app.EnterbetamountLabel.HorizontalAlignment = 'right';
            app.EnterbetamountLabel.FontName = 'Times New Roman';
            app.EnterbetamountLabel.FontSize = 16;
            app.EnterbetamountLabel.FontWeight = 'bold';
            app.EnterbetamountLabel.FontColor = [1 0 0];
            app.EnterbetamountLabel.Enable = 'off';
            app.EnterbetamountLabel.Visible = 'off';
            app.EnterbetamountLabel.Position = [59 424 165 22];
            app.EnterbetamountLabel.Text = 'Enter New Bet Amount';

            % Create dealerTotalCount
            app.dealerTotalCount = uieditfield(app.UIFigure, 'numeric');
            app.dealerTotalCount.Editable = 'off';
            app.dealerTotalCount.HorizontalAlignment = 'center';
            app.dealerTotalCount.FontName = 'Times New Roman';
            app.dealerTotalCount.FontSize = 16;
            app.dealerTotalCount.FontWeight = 'bold';
            app.dealerTotalCount.Visible = 'off';
            app.dealerTotalCount.Position = [211 675 32 22];

            % Create playerTotalCount
            app.playerTotalCount = uieditfield(app.UIFigure, 'numeric');
            app.playerTotalCount.Editable = 'off';
            app.playerTotalCount.HorizontalAlignment = 'center';
            app.playerTotalCount.FontName = 'Times New Roman';
            app.playerTotalCount.FontSize = 16;
            app.playerTotalCount.FontWeight = 'bold';
            app.playerTotalCount.Visible = 'off';
            app.playerTotalCount.Position = [180 119 32 22];

            % Create general_message
            app.general_message = uilabel(app.UIFigure);
            app.general_message.BackgroundColor = [1 0 0];
            app.general_message.HorizontalAlignment = 'center';
            app.general_message.FontSize = 16;
            app.general_message.FontWeight = 'bold';
            app.general_message.FontColor = [1 1 1];
            app.general_message.Visible = 'off';
            app.general_message.Position = [49 236 703 90];
            app.general_message.Text = '';

            % Create new_bet_field
            app.new_bet_field = uieditfield(app.UIFigure, 'numeric');
            app.new_bet_field.RoundFractionalValues = 'on';
            app.new_bet_field.Editable = 'off';
            app.new_bet_field.HorizontalAlignment = 'center';
            app.new_bet_field.FontName = 'Times New Roman';
            app.new_bet_field.FontSize = 16;
            app.new_bet_field.FontWeight = 'bold';
            app.new_bet_field.Enable = 'off';
            app.new_bet_field.Visible = 'off';
            app.new_bet_field.Position = [37 391 57 22];
            app.new_bet_field.Value = 50;

            % Create NewGameButton
            app.NewGameButton = uibutton(app.UIFigure, 'push');
            app.NewGameButton.ButtonPushedFcn = createCallbackFcn(app, @NewGameButtonPushed, true);
            app.NewGameButton.Position = [806 70 189 34];
            app.NewGameButton.Text = 'New Game';

            % Create TutorialButton
            app.TutorialButton = uibutton(app.UIFigure, 'push');
            app.TutorialButton.ButtonPushedFcn = createCallbackFcn(app, @TutorialButtonPushed, true);
            app.TutorialButton.Position = [804 30 194 28];
            app.TutorialButton.Text = 'Tutorial';

            % Create BetAmountLabel
            app.BetAmountLabel = uilabel(app.UIFigure);
            app.BetAmountLabel.BackgroundColor = [0.8 0.8 0.8];
            app.BetAmountLabel.HorizontalAlignment = 'center';
            app.BetAmountLabel.Position = [1 391 97 23];
            app.BetAmountLabel.Text = 'Bet Amount:';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.ScaleMethod = 'fill';
            app.Image.Position = [806 334 195 111];
            app.Image.ImageSource = 'Title.jpg';

            % Create Image2
            app.Image2 = uiimage(app.UIFigure);
            app.Image2.Position = [798 103 200 232];
            app.Image2.ImageSource = 'guide.jpg';

            % Create WINSEditFieldLabel
            app.WINSEditFieldLabel = uilabel(app.UIFigure);
            app.WINSEditFieldLabel.HorizontalAlignment = 'center';
            app.WINSEditFieldLabel.FontColor = [1 1 1];
            app.WINSEditFieldLabel.Position = [797 702 120 22];
            app.WINSEditFieldLabel.Text = 'WINS';

            % Create wins_counter
            app.wins_counter = uieditfield(app.UIFigure, 'text');
            app.wins_counter.Editable = 'off';
            app.wins_counter.Position = [928 702 67 22];

            % Create LOSSESEditFieldLabel
            app.LOSSESEditFieldLabel = uilabel(app.UIFigure);
            app.LOSSESEditFieldLabel.HorizontalAlignment = 'center';
            app.LOSSESEditFieldLabel.FontColor = [1 1 1];
            app.LOSSESEditFieldLabel.Position = [797 667 122 22];
            app.LOSSESEditFieldLabel.Text = 'LOSSES';

            % Create losses_counter
            app.losses_counter = uieditfield(app.UIFigure, 'text');
            app.losses_counter.Editable = 'off';
            app.losses_counter.Position = [930 667 65 22];

            % Create TIESEditFieldLabel
            app.TIESEditFieldLabel = uilabel(app.UIFigure);
            app.TIESEditFieldLabel.HorizontalAlignment = 'center';
            app.TIESEditFieldLabel.FontColor = [1 1 1];
            app.TIESEditFieldLabel.Position = [797 627 120 22];
            app.TIESEditFieldLabel.Text = 'TIES';

            % Create ties_counter
            app.ties_counter = uieditfield(app.UIFigure, 'text');
            app.ties_counter.Editable = 'off';
            app.ties_counter.Position = [928 627 67 22];

            % Create BLACKJACKSEditFieldLabel
            app.BLACKJACKSEditFieldLabel = uilabel(app.UIFigure);
            app.BLACKJACKSEditFieldLabel.HorizontalAlignment = 'center';
            app.BLACKJACKSEditFieldLabel.FontColor = [1 1 1];
            app.BLACKJACKSEditFieldLabel.Position = [797 587 120 22];
            app.BLACKJACKSEditFieldLabel.Text = 'BLACK JACKS';

            % Create blackJack_counter
            app.blackJack_counter = uieditfield(app.UIFigure, 'text');
            app.blackJack_counter.Editable = 'off';
            app.blackJack_counter.Position = [928 587 67 22];

            % Create ConfirmNewBetButton
            app.ConfirmNewBetButton = uibutton(app.UIFigure, 'push');
            app.ConfirmNewBetButton.ButtonPushedFcn = createCallbackFcn(app, @ConfirmNewBetButtonPushed, true);
            app.ConfirmNewBetButton.Visible = 'off';
            app.ConfirmNewBetButton.Position = [85 353 106 22];
            app.ConfirmNewBetButton.Text = 'Confirm New Bet';

            % Create new_game_center
            app.new_game_center = uibutton(app.UIFigure, 'push');
            app.new_game_center.ButtonPushedFcn = createCallbackFcn(app, @NewGameButtonPushed, true);
            app.new_game_center.FontSize = 16;
            app.new_game_center.Visible = 'off';
            app.new_game_center.Position = [295 371 183 62];
            app.new_game_center.Text = 'New Game';

            % Create tutorial
            app.tutorial = uitextarea(app.UIFigure);
            app.tutorial.FontSize = 14;
            app.tutorial.Visible = 'off';
            app.tutorial.Position = [575 103 423 513];
            app.tutorial.Value = {''; '======  Basic Rules ======='; ''; '* Every player starts with 2 cards.'; ''; '* The goal is to get the highest valued hand without going '; 'over a value of 21.'; ''; '* if You get 21, then you automatically Win. Similarlry if dealer gets 21, then He automatically wins.'; ''; '* if You and the dealer have the same total value in your hands, '; '  then it''s Tie'; ''; '* a hand with a higher total than 21 is said to bust.'; ''; '* You can press "HIT" to get a new card, or press "STAND" to '; '   reveal hands and check for winner'; ''; '* The dealer will hit until its hand reaches a value of 17 or greater.'; ''; ''; '=====   Playing the game ======'; '1. Adjust the total amount of money that you have have. The default amount is $1000.'; ''; '2. Change the bet amount, by pressing "CHANGE BET", set, new bet amount, then press "Confirm New Bet". The deafault Bet is $50'; ''; '3. Press DEAL and the game starts. After that you can either press "HIT" to draw a new card or "STAND" to reveal your hand and dealer''s hand and see who is the winner.'; ''; '4. You can press "New Game" to start a new game.'};

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SinglePlayer_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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