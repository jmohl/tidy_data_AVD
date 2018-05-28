source='H:\Data\Lee\ICStudy\ICCellData';
destination='\\ccn-fig\data_drive\Data\Groh_lab_shared_files\Data_for_dual_sound_project\mat\Jungah_mat';
JAL_ICListMaking;  %  creates structure IC_List with all the files

not_found_list=[];
for jjj=1:length(IC_List);
    this_name=IC_List{jjj}
    
    [SUCCESS,MESSAGE,MESSAGEID] = copyfile([source '/' this_name],destination)
    if SUCCESS ~=1
        not_found_list=[not_found_list; cellstr(this_name)];
    end
end
not_found_list

source2='C:\Users\jmgroh\Desktop\JungAh Data\ICCellMatlabData_Loc_DoubleSound\ICCellMatlabData_Loc_DoubleSound';
not_found_list2=[];
for jjj=1:length(not_found_list);
    this_name=not_found_list{jjj};
    [SUCCESS,MESSAGE,MESSAGEID] = copyfile([source2 '/' this_name],destination)
    if SUCCESS ~=1
        not_found_list2=[not_found_list2; cellstr(this_name)];
    end
end
