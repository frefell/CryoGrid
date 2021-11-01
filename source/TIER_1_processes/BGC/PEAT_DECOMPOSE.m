classdef PEAT_DECOMPOSE < BASE
    
    
    methods
        
        function peat = temp_modifier(peat)
            peat.STATVAR.tempModifier = double(peat.STATVAR.T>= -10.0) .* exp(308.56 .* (1.0/40.02 - 1.0./(peat.STATVAR.T + 40.02)));
           % peat.STATVAR.tempModifier = 1;
           peat.STATVAR.tempModifier = peat.STATVAR.tempModifier .* double(peat.STATVAR.T >= 0);
        end
        
        function peat = water_modifier(peat)
           
            range = peat.STATVAR.vol_water > peat.PARA.fieldCapacity;
            peat.STATVAR.waterModifier(range) = 1.0-(1.0-0.025).* ((peat.STATVAR.vol_water(range) - peat.PARA.fieldCapacity)./(1.0-peat.PARA.fieldCapacity)).^3.0;
            range = peat.STATVAR.vol_water >= 0.00 & peat.STATVAR.vol_water <= peat.PARA.fieldCapacity; %CHECK THIS!, should be 0.01 accoriding to Chaudhary 2017?
            peat.STATVAR.waterModifier(range) = 1.0-((peat.PARA.fieldCapacity - peat.STATVAR.vol_water(range))./peat.PARA.fieldCapacity).^5.0;%4.88);//IWRO 5 to 2//4.82
            %peat.STATVAR.tempModifier = 0.1;
        end
        
        function peat = peat_decompose(peat)
            peat.STATVAR.cato = peat.PARA.initialDecomposition.*(peat.STATVAR.total_peat./peat.STATVAR.totalpeatC_originalMass).^peat.PARA.decompo ;  %0.05
            peat.STATVAR.cato(isnan(peat.STATVAR.cato)) = 0; %if totalpeatC_originalMass = 0 
            peat.STATVAR.catm  = peat.STATVAR.cato .* peat.STATVAR.tempModifier .* peat.STATVAR.waterModifier' .* peat.PARA.decompose_timestep; 
             
            peat.TEMP.d_layerThick = peat.TEMP.d_layerThick - peat.STATVAR.catm.*peat.STATVAR.total_peat ./ peat.PARA.bulkDensity; % .* peat.CONST.mtocm; %add changes in bulk density
            peat.TEMP.d_organic = peat.TEMP.d_organic - peat.STATVAR.catm .* peat.STATVAR.total_peat ./ peat.CONST.organicDensity;
            
            
            peat.STATVAR.total_peat = peat.STATVAR.total_peat - peat.STATVAR.catm.*peat.STATVAR.total_peat;
            peat.STATVAR.layerThick = (peat.STATVAR.total_peat./peat.PARA.bulkDensity); %Original must be wrong??? NPP in kg/m2, buld density in kg/m3  .* peat.CONST.mtocm; % g/cm2 ./ cm3/g, then convert with m to cm

        end

    end
end