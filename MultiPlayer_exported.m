classdef MultiPlayer_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        tutorial                  matlab.ui.control.TextArea
        OpponentCardHiddenCard_2  matlab.ui.control.Image
        create_join_game_button   matlab.ui.control.Button
        opponent_blackjack_view   matlab.ui.control.EditField
        P1BlackJacksLabel_2       matlab.ui.control.Label
        new_game_center           matlab.ui.control.Button
        ConfirmNewBetButton       matlab.ui.control.Button
        blackJack_view            matlab.ui.control.EditField
        P1BlackJacksLabel         matlab.ui.control.Label
        ties_counter              matlab.ui.control.EditField
        TIESEditFieldLabel        matlab.ui.control.Label
        losses_counter            matlab.ui.control.EditField
        P1WinsLabel               matlab.ui.control.Label
        wins_counter              matlab.ui.control.EditField
        P1WinsLabel_2             matlab.ui.control.Label
        Image2                    matlab.ui.control.Image
        Image                     matlab.ui.control.Image
        BetAmountLabel            matlab.ui.control.Label
        TutorialButton            matlab.ui.control.Button
        new_bet_field             matlab.ui.control.NumericEditField
        general_message           matlab.ui.control.Label
        playerTotalCount          matlab.ui.control.NumericEditField
        OpponentTotalCount        matlab.ui.control.NumericEditField
        EnterbetamountLabel       matlab.ui.control.Label
        gameStatusText            matlab.ui.control.Label
        total_money_text          matlab.ui.control.TextArea
        TOTALLabel                matlab.ui.control.Label
        betText                   matlab.ui.control.TextArea
        Label                     matlab.ui.control.Label
        OpponentCard5             matlab.ui.control.Image
        OpponentCardHiddenCard    matlab.ui.control.Image
        OpponentCard4             matlab.ui.control.Image
        OpponentCard3             matlab.ui.control.Image
        OpponentCard2             matlab.ui.control.Image
        OpponentCard1             matlab.ui.control.Image
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

   
     properties (Access = private)
        channelID = 2062441;
        writeKey = 'ULHB5ZKDZJV6WCXL';
        readKey = 'T3WPV85H2THEZV9V';
        Deck = 1:52;
        player_hand; 
        opponent_hand; 
        bet_amount = 0;
        player_first_card; % first card value for player
        player_second_card; % second card value for player
        player_new_card; % 3rd and the remaining cards
        opponent_first_card; % first card value for dealer
        opponent_second_card; % second card value for dealer
        opponent_new_card;
        player_wins; % number of wins
        opponent_wins;
        ties; % number of ties
        player_blackjacks = 0; % number of blackjacks
        opponent_blackjacks = 0;
        player_remaining_money; % total money
        player_next_draw = 3; % next card will be the 3rd card for the player
        new_game = 1;
        you_are_the_host = 1;
        quit = 0;
    end
    
    methods (Access = private)
        
        function [card_name,updatedDeck,card_value] = draw_card(app,deck)
            updatedDeck = deck; 
            NamesFile = fopen('cardNames.txt','r');
            if NamesFile == -1, error('Cannot open the file!'); end
            
            cardIndex = randi([1, length(updatedDeck)]);
%             if app.you_are_the_host
%                 pause(0.3);
%                 cardIndex = randi([1, length(updatedDeck)]);
%             end
            
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
                if app.you_are_the_host
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
                end
                app.total_money_text.Editable = 'off';
        
                %reset stats
                app.player_wins = 0;
                app.opponent_wins = 0;
                app.ties = 0;
                app.player_blackjacks = 0;
                app.opponent_blackjacks = 0;
                app.losses_counter.Value = num2str(0);
                app.wins_counter.Value = num2str(0);
                app.ties_counter.Value = num2str(0);
                app.blackJack_view.Value = num2str(0);
                app.opponent_blackjack_view.Value = num2str(0);
                app.new_game = 0;
        end
% ===========================================================================
       
        function initialization(app)
            app.betText.Visible = 'on';
            app.chip_img.Visible = 'on';
            app.player_remaining_money = str2double(app.total_money_text.Value);
            app.bet_amount = str2double(app.betText.Value);
            if app.you_are_the_host
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
            end
            
            app.OpponentTotalCount.Visible = 'off';
            app.playerTotalCount.Visible = 'on';
            
            % load shuffle and deal sound effect
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
            app.OpponentCard1.Visible = 'off';
            app.OpponentCard2.Visible = 'off';
            app.OpponentCard3.Visible = 'off';
            app.OpponentCard4.Visible = 'off';
            app.OpponentCard5.Visible = 'off';
            app.OpponentCardHiddenCard.Visible = 'on';
            app.OpponentCardHiddenCard_2.Visible = 'on';
            app.change_bet_button.Visible = 'off';
            app.dealButton.Visible = 'off';

        end


% ===========================================================================

        function show_win_screen(app)
            app.standButton.Visible = 'off';
            app.hitButton.Visible = 'off';
            app.player_remaining_money = app.player_remaining_money + app.bet_amount;
            app.total_money_text.Value = num2str(app.player_remaining_money);
            app.gameStatusText.Text = "YOU WIN!";
            app.gameStatusText.Visible = 'on';
            [ya, Fs,] = audioread('YouWin.mp3');
            sound (ya, Fs);  pause(4);
            app.player_wins = app.player_wins + 1;
            app.wins_counter.Value = num2str(app.player_wins);
            pause(1);
            app.gameStatusText.Text = "";
            app.gameStatusText.Visible = 'off';
        end
% ===========================================================================
        function show_loss_screen(app)
            app.standButton.Visible = 'off';
            app.hitButton.Visible = 'off';
            app.player_remaining_money = app.player_remaining_money - app.bet_amount;
            app.total_money_text.Value = num2str(app.player_remaining_money);
            app.gameStatusText.Text = "YOU LOSE";
            app.gameStatusText.Visible = 'on';
            [ya, Fs,] = audioread('YouLose.mp3');
            sound (ya, Fs);  pause(4);
            app.opponent_wins = app.opponent_wins + 1;
            app.losses_counter.Value = num2str(app.opponent_wins);
            pause(1);
            app.gameStatusText.Text = "";
            app.gameStatusText.Visible = 'off';
        end
% ===========================================================================
        
        function reset(app)
            if app.player_remaining_money <= 0 
                app.gameStatusText.Text = "GAME OVER. You run out of Money";
                app.gameStatusText.Visible = 'on';
                pause(4);
                app.gameStatusText.Visible = 'off';
                app.chip_img.Visible = 'off';
            else
                app.gameStatusText.Visible = 'off';
                app.standButton.Visible = 'off';
                app.hitButton.Visible = 'off';
                app.general_message.Visible = 'off';
                pause(1);
                app.playerCard1.Visible = 'off';
                app.playerCard2.Visible = 'off';
                app.playerCard3.Visible = 'off';
                app.playerCard4.Visible = 'off';
                app.playerCard5.Visible = 'off';
                
                app.OpponentCard1.Visible = 'off';
                app.OpponentCard2.Visible = 'off';
                app.OpponentCard3.Visible = 'off';
                app.OpponentCard4.Visible = 'off';
                app.OpponentCard5.Visible = 'off';
                app.OpponentCardHiddenCard.Visible = 'on';
                app.OpponentTotalCount.Value = 0;
                app.playerTotalCount.Value = 0;
                app.OpponentTotalCount.Visible = 'off';
                app.chip_img.Visible = 'off';
                app.player_next_draw = 3;
                app.player_hand = 0;
                app.opponent_hand = 0;
                app.Deck = 1:52;
            end
            app.dealPushed(app);
        

        end
% ===========================================================================
        
    function show_opponent_hand(app)
        app.OpponentCardHiddenCard.Visible = 'off';
        app.OpponentCardHiddenCard_2.Visible = 'off';
        
        if app.you_are_the_host
            % === steps taken by the 1st player ===

            %push player 1 hand to thingspeak
            push_values = ["dummy"];
            push_values(1) = app.playerCard1.ImageSource;
            push_values(2) = app.playerCard2.ImageSource;
            if app.player_next_draw > 3
                push_values(3) = app.playerCard3.ImageSource;
            else
                push_values(3) = "front.png";
            end
            if app.player_next_draw > 4
                push_values(4) = app.playerCard4.ImageSource;
            else
                push_values(4) = "front.png";
            end
            if app.player_next_draw > 5
                push_values(5) = app.playerCard5.ImageSource;
            else
                push_values(5) = "front.png";
            end
       
            push_values(6) = app.player_hand;
            push_values(7) = 1; %let player 2 know that you pushed
            pause(1);
            thingSpeakWrite(app.channelID,'Writekey',app.writeKey,'Fields',[1,2,3,4,5,6,7],'Values',push_values);

            % wait for player 2 cards to be pushed to thingspeak
            cards_pushed = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',8);
            while (isnan(cards_pushed) || not(cards_pushed) || app.quit)
                pause(0.5);
                cards_pushed = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',8);
            end
            
            % read player 2 hand  from thingspeak
             out = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',[1,2,3,4,5,6], OutputFormat='table');
             im1 = string(out(1,2).(1));  %converts table entry to cell, then to string
             im2 = string(out(1,3).(1));
             im3 = string(out(1,4).(1));
             im4 = string(out(1,5).(1));
             im5 = string(out(1,6).(1));
             app.opponent_hand = str2double(string(out(1,7).(1)));
            % show player 2 hand
            app.OpponentCard1.ImageSource = im1;
            app.OpponentCard1.Visible = 'on';
            app.OpponentCard2.ImageSource = im2;
            app.OpponentCard2.Visible = 'on';
            if im3 ~= "front.png"
                app.OpponentCard3.ImageSource = im3;
                app.OpponentCard3.Visible = 'on';
            end
            if im4 ~= "front.png"
                app.OpponentCard4.ImageSource = im4;
                app.OpponentCard4.Visible = 'on';
            end
            if im5 ~= "front.png"
                app.OpponentCard5.ImageSource = im5;
                app.OpponentCard5.Visible = 'on';
            end
            app.OpponentTotalCount.Value = app.opponent_hand;
            app.OpponentTotalCount.Visible = 'on';
            pause(1);
            thingSpeakWrite(app.channelID,'Writekey',app.writeKey,'Fields',1,'Values',0);

        else
            % === steps taken by the 2nd player ===

            % wait for player 1 cards to be pushed to thingspeak
            cards_pushed = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',7);
            while (isnan(cards_pushed) || not(cards_pushed) || app.quit)
                pause(0.1);
                cards_pushed = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',7);
            end

            % read player 1 hand  from thingspeak
             out = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',[1,2,3,4,5,6], OutputFormat='table');
             im1 = string(out(1,2).(1));  %converts table entry to cell, then to string
             im2 = string(out(1,3).(1));
             im3 = string(out(1,4).(1));
             im4 = string(out(1,5).(1));
             im5 = string(out(1,6).(1));
             app.opponent_hand = str2double(string(out(1,7).(1)));

            %push player 2 hand to thingspeak
            push_values = ["dummy"];
            push_values(1) = app.playerCard1.ImageSource;
            push_values(2) = app.playerCard2.ImageSource;
            if app.player_next_draw > 3
                push_values(3) = app.playerCard3.ImageSource;
            else
                push_values(3) = "front.png";
            end
            if app.player_next_draw > 4
                push_values(4) = app.playerCard4.ImageSource;
            else
                push_values(4) = "front.png";
            end
            if app.player_next_draw > 5
                push_values(5) = app.playerCard5.ImageSource;
            else
                push_values(5) = "front.png";
            end
            push_values(6) = app.player_hand;
            push_values(7) = 1; %let player 1 know that you pushed
            pause(1);
            thingSpeakWrite(app.channelID,'Writekey',app.writeKey,'Fields',[1,2,3,4,5,6,8],'Values',push_values);

                         
            % show player 1 hand
            app.OpponentCard1.ImageSource = im1;
            app.OpponentCard1.Visible = 'on';
            app.OpponentCard2.ImageSource = im2;
            app.OpponentCard2.Visible = 'on';
            if im3 ~= "front.png"
                app.OpponentCard3.ImageSource = im3;
                app.OpponentCard3.Visible = 'on';
            end
            if im4 ~= "front.png"
                app.OpponentCard4.ImageSource = im4;
                app.OpponentCard4.Visible = 'on';
            end
            if im5 ~= "front.png"
                app.OpponentCard5.ImageSource = im5;
                app.OpponentCard5.Visible = 'on';
            end
            app.OpponentTotalCount.Value = app.opponent_hand;
            app.OpponentTotalCount.Visible = 'on';
        end
            
                
    end
        
    function result = check_for_winner(app)
    %  output: 
    %        1: player  won
    %        2: Opponent won
    %        3: Tie
        if (app.player_hand == 21) && (app.opponent_hand ~= 21)
            result = 1;
        elseif (app.opponent_hand == 21) && (app.player_hand ~= 21)
            result = 2;
        elseif (app.player_hand >= 21) && (app.opponent_hand >= 21)
            %Both busted, or both 21
            result = 3;
        elseif (app.player_hand < 21) && (app.opponent_hand > 21)
            %Opponent busted
            result = 1;
        elseif (app.player_hand > 21) && (app.opponent_hand < 21)
            %Player busted
            result = 2;
        
        elseif (app.player_hand > app.opponent_hand)
            %Player WON
            result = 1;
        elseif (app.player_hand < app.opponent_hand)
            % opponent won
            result = 2;
        else
            result = 3; % TIE
        end
        if app.player_hand == 21
            app.player_blackjacks = app.player_blackjacks +1;
            app.blackJack_view.Value = num2str(app.player_blackjacks);
        end
        if app.opponent_hand == 21
            app.opponent_blackjacks = app.opponent_blackjacks +1;
            app.opponent_blackjack_view.Value = num2str(app.opponent_blackjacks);
        end
            
    end
        
%     function waiting_p1_deal(app)
%         app.BetAmountLabel.Visible = 'on';
%         app.betText.Visible = 'on';
%         app.general_message.Text = "Waiting for Player 1 to Deal the cards";
%         app.general_message.Visible = 'on';
%         player1_delt_cards = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',3);
%         i = 0;
%         while (isnan(player1_delt_cards) || not(player1_delt_cards) || app.quit)
%             pause(0.5);
%             if (i == 5)
%                 app.general_message.Text = "Waiting for Player 1 to Deal the cards";
%                 i = 0;
%             else
%                 i = i+1;
%                 app.general_message.Text = app.general_message.Text + ".";
%             end
%             player1_delt_cards = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',3);
%             
%         end
%         %if reached here, then it means player1 pushed deal
%         initialization(app);
%         deck = app.Deck;
%         [card_name,deck, app.player_first_card] = draw_card(app,deck); %draw first card
%         app.playerCard1.ImageSource = card_name; %get the image of the card
%         [card_name,deck,app.player_second_card] = draw_card(app,deck); %draw second card
%         app.playerCard2.ImageSource = card_name;
% 
%         %An ace's value is 11 unless this would 
%         %cause the player to bust, in which case it is worth 1
%         total = app.player_first_card + app.player_second_card;
%         if (total > 21)
%             if app.player_first_card == 11,   app.player_first_card = 1; end
%             if app.player_second_card == 11,  app.player_second_card = 1; end
%         end
%         app.player_hand = app.player_first_card + app.player_second_card;
%         app.playerTotalCount.Value = app.player_hand;
%             
%     end
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
%             if app.you_are_the_host
%                 pause(1);
%                 thingSpeakWrite(app.channelID,'Writekey',app.writeKey,'Fields',1,'Values',1); %push new bet amount
%             end

            
        end

        % Button pushed function: dealButton
        function dealPushed(app, event)
            app.general_message.Visible = 'off';
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
           
            if app.you_are_the_host
                 pause(1);
                 money = app.player_remaining_money;
                 thingSpeakWrite(app.channelID,'Writekey',app.writeKey,'Fields',[1,2,3],'Values',[1,money,app.bet_amount]); % player1_delt_cards = True
            end

            
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
                    standPushed(app, event);
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
            if app.player_hand > 21
                %busted, no need to draw more cards
                standPushed(app, event);
            end
            
            
        end

        % Button pushed function: standButton
        function standPushed(app, event)
             app.standButton.Visible = 'off';
             app.hitButton.Visible = 'off';

             if app.you_are_the_host
                 % === Steps taken by player 1 ====
                 pause(1);
                 thingSpeakWrite(app.channelID,'Writekey',app.writeKey,'Fields',4,'Values',1); % player1_pressed_stand = True
                
                 %wait for P2 to press stand
                app.general_message.Text = "Waiting for Opponent to press Stand";
                app.general_message.Visible = 'on';
                player2_pressed_stand = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',5);
                i = 0;
                while (isnan(player2_pressed_stand) || not(player2_pressed_stand) || app.quit)
                    pause(0.5);
                    if (i == 5)
                        app.general_message.Text = "Waiting for Opponent to press Stand";
                        i = 0;
                    else
                        i = i+1;
                        app.general_message.Text = app.general_message.Text + ".";
                    end
                    player2_pressed_stand = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',5);
                end
                %if reached here, then it means player 2 pressed stand
                app.general_message.Visible = 'off';
                
             else 
                 % === Steps taken by player 2 =====
                 
                 % wait for P1 to press stand
                app.general_message.Text = "Waiting for Opponent to press Stand";
                app.general_message.Visible = 'on';
                player1_pressed_stand = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',4);
                i = 0;
                while (isnan(player1_pressed_stand) || not(player1_pressed_stand) || app.quit)
                    pause(0.5);
                    if (i == 5)
                        app.general_message.Text = "Waiting for Opponent to press Stand";
                        i = 0;
                    else
                        i = i+1;
                        app.general_message.Text = app.general_message.Text + ".";
                    end
                    player1_pressed_stand = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',4);
                end
                %if reached here, then it means player 1 pressed stand
                pause(1)
                thingSpeakWrite(app.channelID,'Writekey',app.writeKey,'Fields',5,'Values',1); % player2_pressed_stand = True
                app.general_message.Visible = 'off';
             end
             % === Both players take these steps ===
             show_opponent_hand(app);
             result = check_for_winner(app);

             switch result
                 case 1
                     % You WON
                     show_win_screen(app);
                 case 2
                     show_loss_screen(app);
                 case 3
                     %TIE
                     app.gameStatusText.Text = "TIE";
                     app.gameStatusText.Visible = 'on';
                     pause(4);
                     app.ties = app.ties + 1;
                     app.ties_counter.Value = num2str(app.ties);
             end
             reset(app);



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

        % Button pushed function: create_join_game_button
        function StartButtonPushed(app, event)
            app.create_join_game_button.Visible = 'off';
            player1_created_game = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',1);
            if isnan(player1_created_game) || not(player1_created_game)
                %then you are the host
                app.you_are_the_host = 1;
                pause(1);
                thingSpeakWrite(app.channelID,'Writekey',app.writeKey,'Fields',[1,2],'Values',[1,0]); % player1_created_game = True
            else
                %then you just joining the game
                app.you_are_the_host = 0;
                pause(1);
                thingSpeakWrite(app.channelID,'Writekey',app.writeKey,'Fields',[1,2],'Values',[1,1]); % player2_joined_game = True
            end
            
            if app.you_are_the_host
                % === Steps taken by player 1 ===

                % wait for player 2 to join
                app.general_message.Text = "Waiting for Player 2 to join the game";
                app.general_message.Visible = 'on';
                player2_joined_game = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',2);
                i = 0;
                while (isnan(player2_joined_game) || not(player2_joined_game) || app.quit)
                    pause(0.5);
                    if (i == 5)
                        app.general_message.Text = "Waiting for Player 2 to join the game";
                        i = 0;
                    else
                        i = i+1;
                        app.general_message.Text = app.general_message.Text + ".";
                    end
                    player2_joined_game = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',2);
                end
%                 % if reached here, then it means player 2 joined the game
                app.general_message.Visible = 'off';
                app.dealButton.Visible = 'on';
                app.change_bet_button.Visible = 'on';
                app.BetAmountLabel.Visible = 'on';
                app.betText.Visible = 'on';

             else % These steps taken by player 2
                app.BetAmountLabel.Visible = 'on';
                app.betText.Visible = 'on';
                app.general_message.Text = "Waiting for Player 1 to Deal the cards";
                app.general_message.Visible = 'on';
                player1_delt_cards = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',3);
                i = 0;
                while (isnan(player1_delt_cards) || not(player1_delt_cards) || app.quit)
                    pause(0.5);
                    if (i == 5)
                        app.general_message.Text = "Waiting for Player 1 to Deal the cards";
                        i = 0;
                    else
                        i = i+1;
                        app.general_message.Text = app.general_message.Text + ".";
                    end
                    player1_delt_cards = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',3);
                    
                end
                
                %if reached here, then it means player1 pushed deal
                app.player_remaining_money = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',2);
                app.total_money_text.Value = num2str(app.player_remaining_money);
                app.bet_amount = thingSpeakRead(app.channelID,'ReadKey',app.readKey,'Fields',3);
                app.betText.Value = num2str(app.bet_amount);
                
                dealPushed(app,event);

            end
                



        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            app.quit = 1;
            pause(1);
            thingSpeakWrite(app.channelID,'Writekey',app.writeKey,'Fields',[1,2],'Values',[0,0]); % reset game_created to False
            delete(app);
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
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create ignoreIt
            app.ignoreIt = uiaxes(app.UIFigure);
            app.ignoreIt.Toolbar.Visible = 'off';
            app.ignoreIt.FontName = 'Times New Roman';
            app.ignoreIt.FontWeight = 'bold';
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
            app.dealButton.Visible = 'off';
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
            app.change_bet_button.Visible = 'off';
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

            % Create OpponentCard1
            app.OpponentCard1 = uiimage(app.UIFigure);
            app.OpponentCard1.Visible = 'off';
            app.OpponentCard1.Position = [244 648 71 76];
            app.OpponentCard1.ImageSource = 'front.png';

            % Create OpponentCard2
            app.OpponentCard2 = uiimage(app.UIFigure);
            app.OpponentCard2.Visible = 'off';
            app.OpponentCard2.Position = [295 648 71 76];
            app.OpponentCard2.ImageSource = 'front.png';

            % Create OpponentCard3
            app.OpponentCard3 = uiimage(app.UIFigure);
            app.OpponentCard3.Visible = 'off';
            app.OpponentCard3.Position = [346 648 71 76];
            app.OpponentCard3.ImageSource = 'front.png';

            % Create OpponentCard4
            app.OpponentCard4 = uiimage(app.UIFigure);
            app.OpponentCard4.Visible = 'off';
            app.OpponentCard4.Position = [397 648 71 76];
            app.OpponentCard4.ImageSource = 'front.png';

            % Create OpponentCardHiddenCard
            app.OpponentCardHiddenCard = uiimage(app.UIFigure);
            app.OpponentCardHiddenCard.Visible = 'off';
            app.OpponentCardHiddenCard.Position = [296 648 69 76];
            app.OpponentCardHiddenCard.ImageSource = 'card_back.png';

            % Create OpponentCard5
            app.OpponentCard5 = uiimage(app.UIFigure);
            app.OpponentCard5.Visible = 'off';
            app.OpponentCard5.Position = [448 648 71 76];
            app.OpponentCard5.ImageSource = 'front.png';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.VerticalAlignment = 'top';
            app.Label.FontName = 'Times New Roman';
            app.Label.FontSize = 16;
            app.Label.FontWeight = 'bold';
            app.Label.FontColor = [0.9412 0.9412 0.9412];
            app.Label.Visible = 'off';
            app.Label.Position = [79 391 29 22];
            app.Label.Text = '$';

            % Create betText
            app.betText = uitextarea(app.UIFigure);
            app.betText.Editable = 'off';
            app.betText.HorizontalAlignment = 'center';
            app.betText.FontName = 'Times New Roman';
            app.betText.FontSize = 16;
            app.betText.FontWeight = 'bold';
            app.betText.Visible = 'off';
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

            % Create OpponentTotalCount
            app.OpponentTotalCount = uieditfield(app.UIFigure, 'numeric');
            app.OpponentTotalCount.Editable = 'off';
            app.OpponentTotalCount.HorizontalAlignment = 'center';
            app.OpponentTotalCount.FontName = 'Times New Roman';
            app.OpponentTotalCount.FontSize = 16;
            app.OpponentTotalCount.FontWeight = 'bold';
            app.OpponentTotalCount.Visible = 'off';
            app.OpponentTotalCount.Position = [211 675 32 22];

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

            % Create TutorialButton
            app.TutorialButton = uibutton(app.UIFigure, 'push');
            app.TutorialButton.ButtonPushedFcn = createCallbackFcn(app, @TutorialButtonPushed, true);
            app.TutorialButton.Position = [806 53 192 40];
            app.TutorialButton.Text = 'Tutorial';

            % Create BetAmountLabel
            app.BetAmountLabel = uilabel(app.UIFigure);
            app.BetAmountLabel.BackgroundColor = [0.8 0.8 0.8];
            app.BetAmountLabel.HorizontalAlignment = 'center';
            app.BetAmountLabel.Visible = 'off';
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

            % Create P1WinsLabel_2
            app.P1WinsLabel_2 = uilabel(app.UIFigure);
            app.P1WinsLabel_2.HorizontalAlignment = 'center';
            app.P1WinsLabel_2.FontColor = [1 1 1];
            app.P1WinsLabel_2.Position = [797 702 120 22];
            app.P1WinsLabel_2.Text = 'Your Wins';

            % Create wins_counter
            app.wins_counter = uieditfield(app.UIFigure, 'text');
            app.wins_counter.Editable = 'off';
            app.wins_counter.Position = [928 702 67 22];

            % Create P1WinsLabel
            app.P1WinsLabel = uilabel(app.UIFigure);
            app.P1WinsLabel.HorizontalAlignment = 'center';
            app.P1WinsLabel.FontColor = [1 1 1];
            app.P1WinsLabel.Position = [797 667 122 22];
            app.P1WinsLabel.Text = 'Opponent Wins';

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

            % Create P1BlackJacksLabel
            app.P1BlackJacksLabel = uilabel(app.UIFigure);
            app.P1BlackJacksLabel.HorizontalAlignment = 'center';
            app.P1BlackJacksLabel.FontColor = [1 1 1];
            app.P1BlackJacksLabel.Position = [797 587 120 22];
            app.P1BlackJacksLabel.Text = 'Your BlackJacks';

            % Create blackJack_view
            app.blackJack_view = uieditfield(app.UIFigure, 'text');
            app.blackJack_view.Editable = 'off';
            app.blackJack_view.Position = [928 587 67 22];

            % Create ConfirmNewBetButton
            app.ConfirmNewBetButton = uibutton(app.UIFigure, 'push');
            app.ConfirmNewBetButton.ButtonPushedFcn = createCallbackFcn(app, @ConfirmNewBetButtonPushed, true);
            app.ConfirmNewBetButton.Visible = 'off';
            app.ConfirmNewBetButton.Position = [85 353 106 22];
            app.ConfirmNewBetButton.Text = 'Confirm New Bet';

            % Create new_game_center
            app.new_game_center = uibutton(app.UIFigure, 'push');
            app.new_game_center.FontSize = 16;
            app.new_game_center.Visible = 'off';
            app.new_game_center.Position = [295 371 183 62];
            app.new_game_center.Text = 'New Game';

            % Create P1BlackJacksLabel_2
            app.P1BlackJacksLabel_2 = uilabel(app.UIFigure);
            app.P1BlackJacksLabel_2.HorizontalAlignment = 'center';
            app.P1BlackJacksLabel_2.FontColor = [1 1 1];
            app.P1BlackJacksLabel_2.Position = [797 546 120 22];
            app.P1BlackJacksLabel_2.Text = 'Opponent Blackjacks';

            % Create opponent_blackjack_view
            app.opponent_blackjack_view = uieditfield(app.UIFigure, 'text');
            app.opponent_blackjack_view.Editable = 'off';
            app.opponent_blackjack_view.Position = [928 546 67 22];

            % Create create_join_game_button
            app.create_join_game_button = uibutton(app.UIFigure, 'push');
            app.create_join_game_button.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.create_join_game_button.BackgroundColor = [1 0 0];
            app.create_join_game_button.FontSize = 20;
            app.create_join_game_button.FontWeight = 'bold';
            app.create_join_game_button.FontColor = [1 1 1];
            app.create_join_game_button.Position = [303 457 183 62];
            app.create_join_game_button.Text = 'START';

            % Create OpponentCardHiddenCard_2
            app.OpponentCardHiddenCard_2 = uiimage(app.UIFigure);
            app.OpponentCardHiddenCard_2.Visible = 'off';
            app.OpponentCardHiddenCard_2.Position = [242 648 69 76];
            app.OpponentCardHiddenCard_2.ImageSource = 'card_back.png';

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
        function app = MultiPlayer_exported

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